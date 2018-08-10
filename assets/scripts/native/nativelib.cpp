#include "inc/misc/resource_stats.hpp"

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *opts) {
    godot::Godot::gdnative_init(opts);
}

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *opts) {
    godot::Godot::gdnative_terminate(opts);
}

extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
    godot::Godot::nativescript_init(handle);

    // List of classes here
    godot::register_class<godot::resource_stats>();
}
