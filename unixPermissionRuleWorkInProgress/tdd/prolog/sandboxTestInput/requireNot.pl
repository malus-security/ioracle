%It should be impossible for an entitlement to have more than one value, so I'm assuming the list following the key can have one value or zero.
%Where zero entitlement values represents the bool true entitlement value.

%vnode types seem to include (DIRECTORY, REGULAR FILE, SYMLINK, BLOCK-DEVICE, CHARACTER-DEVICE, TTY)
%TODO ask Razvan if there could be more.
vnodeType(file("/a/dir"),type(directory)).
vnodeType(file("/b/dir"),type(directory)).

vnodeType(file("/a/reg"),type(regular-file)).
vnodeType(file("/b/reg"),type(regular-file)).

vnodeType(file("/a/sym"),type(symlink)).
vnodeType(file("/b/sym"),type(symlink)).

vnodeType(file("/a/block"),type(block-device)).
vnodeType(file("/b/block"),type(block-device)).

vnodeType(file("/a/char"),type(character-device)).
vnodeType(file("/b/char"),type(character-device)).

vnodeType(file("/a/tty"),type(tty)).
vnodeType(file("/b/tty"),type(tty)).



%should match
profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  vnode-type(regular-file),
  require-not(require-entitlement("rootBool",[]))
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  vnode-type(symlink),
  require-not(require-entitlement("impossibleBool",[]))
])).

profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  vnode-type(tty),
  require-not(literal("/a/tty"))
])).



%should fail to match
profileRule(profile("rootProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  vnode-type(block-device),
  require-not(require-entitlement("rootBool",[]))
])).

profileRule(profile("mobileProcessProfile"),decision("allow"),operation("doTheThing"),filters([
  %ends in 4 or 5, so should match /thefile4 and /thefile5
  require-not(regex("^.*$"/i))
])).
