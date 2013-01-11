$foo = { 'a' => { 'c' => 'message' } }

notify { 'demo_1':
  message => nested_value($foo, ['a', 'b']),
}

notify { 'demo_2':
  message => nested_value($foo, ['a', 'c']),
}
