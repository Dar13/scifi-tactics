#include "inc/misc/resource_stats.hpp"

#include <Engine.hpp>
#include <Performance.hpp>
#include <MainLoop.hpp>
#include <SceneTree.hpp>

using namespace godot;

void resource_stats::_register_methods() {
    register_method((char*)"_enter_tree", &resource_stats::_enter_tree);
    register_method((char*)"_exit_tree", &resource_stats::_exit_tree);
    register_method((char*)"_notification", &resource_stats::_notification);
    register_method((char*)"get_test_property", &resource_stats::get_test_property);
}

resource_stats::resource_stats() { }

resource_stats::~resource_stats() { }

void resource_stats::_notification(int what) {
    if(what == MainLoop::NOTIFICATION_WM_QUIT_REQUEST) {
        global_state_ptr->set("quit_requested", 1);
        print_stats("quit");
        this->owner->get_tree()->change_scene("res://assets/scenes/shutdown_scene.tscn");
    }
}

void resource_stats::_enter_tree() {
    this->global_state_ptr = this->owner->get_node("/root/global_state");
    print_stats("enter tree");
    if((int)global_state_ptr->get("quit_requested") == 1) {
        this->owner->get_tree()->quit();
    }
    
}

void resource_stats::_exit_tree() {
    print_stats("exit tree");
}

void resource_stats::print_stats(const char *phase) {
    Performance *perfm = reinterpret_cast<Performance*>(Engine::get_singleton("Performance"));
    long object_count = std::lround(perfm->get_monitor(Performance::OBJECT_COUNT));
    long static_mem = std::lround(perfm->get_monitor(Performance::MEMORY_STATIC));
    long dyn_mem = std::lround(perfm->get_monitor(Performance::MEMORY_DYNAMIC));
    Godot::print("Statistics at \'{0}\':", phase);
    Godot::print(" - Object count = {0}", object_count);
    Godot::print(" - Static memory = {0}", static_mem);
    Godot::print(" - Dynamic memory = {0}", dyn_mem);
}

Variant resource_stats::get_test_property() const {
    return test_property;
}
