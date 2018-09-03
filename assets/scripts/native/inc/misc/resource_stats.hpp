#ifndef RES_STATS_H
#define RES_STATS_H

#include <Godot.hpp>
#include <Node.hpp>

/*
 * This is an example class showing how a C++ script in Godot can work.
 * Specifically it shows how to:
 *      - Print to stdout
 *      - Retrieve/use global singleton object (both user-defined and Engine)
 *      - Register/handle notifications
 *      - Switch scenes
 */

namespace godot {
    class resource_stats : public godot::GodotScript<Node> {
        GODOT_CLASS(resource_stats)

        private:
            Node *global_state_ptr;
            void print_stats(const char *phase);

        public:
            static void _register_methods();

            resource_stats();
            ~resource_stats();

            void _notification(int what);
            void _enter_tree();
            void _exit_tree();
    };
}

#endif  // RES_STATS_H
