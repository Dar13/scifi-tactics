#ifndef END_STATS_H
#define END_STATS_H

#include <Godot.hpp>
#include <Node.hpp>

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

#endif
