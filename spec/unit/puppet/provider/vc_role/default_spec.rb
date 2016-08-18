require 'spec_helper'

provider_class = Puppet::Type.type(:vc_role).provider(:vc_role)

describe provider_class do

  let :resource do
    Puppet::Type::Vc_role.new(
      { :name => 'Test_Role2', :privileges => [ 'priv1', 'priv2' ], :force_delete => 'true' }
    )
  end

  let :provider do
    provider_class.new(resource)
  end

  let :authorizationManager do
    double
  end

  before :each do
    # Mock AuthenticationManager that will be used to retrieve, modify and create roles
    # Made an instance variable to overwrite in supplemental tests
    @fake_authManager = double
    provider.stubs(:authorizationManager).returns(@fake_authManager)

    # Mock 3 roles to simulate the return of multiple roles from the AuthenticationManager
    fake_role_1 = double
    allow(fake_role_1).to receive(:name).and_return('Test_Role1')
    fake_role_2 = double
    allow(fake_role_2).to receive(:name).and_return('Test_Role2')
    # Added roleId and privilege to fake_resource_2 since this is the object that will match the resource query
    # These attribute will be required for modification or deletion of the resource
    allow(fake_role_2).to receive(:roleId).and_return(1)
    allow(fake_role_2).to receive(:privilege).and_return( [ 'System.Anonymous', 'System.Read', 'System.View', 'priv1' ] )
    fake_role_3 = double
    allow(fake_role_3).to receive(:name).and_return('Test_Role3')
    fake_role_list = [
      fake_role_1,
      fake_role_2,
      fake_role_3
    ]
    allow(@fake_authManager).to receive(:roleList).and_return( fake_role_list )

    # Mock list of privileges for validating resource[:privileges]
    fake_priv_1 = double
    allow(fake_priv_1).to receive(:privId).and_return('priv1')
    fake_priv_2 = double
    allow(fake_priv_2).to receive(:privId).and_return('priv2')
    fake_priv_3 = double
    allow(fake_priv_3).to receive(:privId).and_return('priv3')
    fake_privilege_list = [
      fake_priv_1,
      fake_priv_2,
      fake_priv_3
    ]
    allow(@fake_authManager).to receive(:privilegeList).and_return( fake_privilege_list )
  end # End before :each do

  context 'validate_privileges' do
    it 'should have a list of valid_privileges' do
      privileges = provider.send(:valid_privileges)
      expect( privileges ).to be_a_kind_of(::Array)
      expect( privileges ).to_not be_empty
    end

    it 'should raise on error if resource[:privileges] includes an invalid privilege' do
      #Overwrite the return of privilegeList to mock false privileges
      allow(@fake_authManager).to receive(:privilegeList).and_return( [] )
      expect{ provider.send(:validate_privileges) }.to raise_error(Puppet::Error, "Invalid privileges: [\"priv1\", \"priv2\"]. Valid values are []")
    end
  end # End context 'validate_privileges' do

  context 'exists?' do
    it 'should return true when a role is found matching resource[:name]' do
      expect(provider.exists?).to be_truthy
    end

    it 'should return false when a role is not found matching resource[:name]' do
      # Overwrite the stubbed return of the roleList method to simulate no returned roles
      allow(@fake_authManager).to receive(:roleList).and_return( [] )
      expect(provider.exists?).to be_falsey
    end
  end # End context 'exists?' do

  context 'create' do
    before :each do
      allow(@fake_authManager).to receive(:AddAuthorizationRole).with(Hash)
    end

    it 'should validate_privileges' do
      # Overwrite the stubbed return of privilegeList to mock false privileges
      allow(@fake_authManager).to receive(:privilegeList).and_return( [] )
      expect{ provider.create }.to raise_error(Puppet::Error, "Invalid privileges: [\"priv1\", \"priv2\"]. Valid values are []")
    end

    it 'should create a new role' do
      expect{ provider.create }.to_not raise_error
    end
  end # End context 'create' do

  context 'destroy' do
    before :each do
      allow(@fake_authManager).to receive(:RemoveAuthorizationRole).with(Hash)
    end

    it 'should set failIfUsed to false if resource[:force_delete] is true' do
      resource[:force_delete] = :true
      expect( provider.send(:failIfUsed) ).to eq('false') 
    end

    it 'should set failIfUsed to true if resource[:force_delete] is false' do
      resource[:force_delete] = :false
      expect( provider.send(:failIfUsed) ).to eq('true') 
    end

    it 'should delete the role' do
      expect{ provider.destroy }.to_not raise_error
    end
  end # End context 'destroy' do

  context 'privileges' do
    it 'should return an array of privileges for the rources' do
      expect( provider.privileges).to be_a_kind_of(::Array)
    end

    it 'should strip out default permissions' do
      resource[:privileges] = 
      expect( provider.privileges).to eq( [ 'priv1' ] )
    end
  end # End context 'privileges' do

  context 'privileges=' do
    it 'should validate_privileges' do
      # Overwrite the stubbed return of privilegeList to mock false privileges
      allow(@fake_authManager).to receive(:privilegeList).and_return( [] )
      expect{ provider.privileges=( [ "priv1", "priv2" ] ) }.to raise_error(Puppet::Error, "Invalid privileges: [\"priv1\", \"priv2\"]. Valid values are []")
    end

    it 'should set @flush_required to true' do
      expect{ provider.privileges=( [ "priv1", "priv2" ] ) }.to_not raise_error
      expect( provider.instance_variable_get(:@flush_required) ).to eq(true)
    end

    it 'should set config_should[:privileges]' do
      expect{ provider.privileges=( [ "priv1", "priv2" ] ) }.to_not raise_error
      expect( provider.config_should[:privileges] ).to eq( [ "priv1", "priv2" ] )
    end
  end # End context 'privileges' do

  context 'flush' do
    it 'should do nothing if @flush_required is false' do
      provider.instance_variable_set(:@flush_required, false)
      expect( provider.instance_variable_get(:@flush_required) ).to eq(false)
      expect{ provider.flush }.to_not raise_error
    end

    it 'should update the role when @flush_required is true' do
      allow(@fake_authManager).to receive(:UpdateAuthorizationRole).with(Hash)
      provider.privileges=( [ "priv1", "priv2" ] )
      expect( provider.instance_variable_get(:@flush_required) ).to eq(true)
      expect{ provider.flush }.to_not raise_error
    end 
  end # End context 'flush' do
end
