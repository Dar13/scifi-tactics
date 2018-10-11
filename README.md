# This is very heavily a work-in-progress. Stay tuned.

Refer to LICENSE.md for license information.

To build/run, it's necessary to do the following after cloning:
```
git submodules init
git submodules update
cd ./assets/scripts/native
scons p=x11
```

It's also assumed that you have an independently built version of Godot.
The precise compatible version is a moving target, but Godot 3.0.6+/3.1+ is necessary.
