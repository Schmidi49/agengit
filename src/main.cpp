#include <iostream>
#include <vector>
#include <string>
#include <stdexcept>
#include "rules.h"

#include "OS.h"

int main(int argc, char* argv[]) {
    try {
        std::vector<std::string> args;
        for (int i = 1; i < argc; ++i) {
            args.push_back(argv[i]);
        }

        PolicyDecision decision = evaluate_policy(args);

        if (decision.policy == CommandPolicy::ALLOW) {
            return execute_command(args);
        } else if (decision.policy == CommandPolicy::DENY) {
            std::cout << "#### PERMISSION DENIED ####\n";
            std::cout << decision.explanation << "\n";
            return 1;
        } else {
            // CommandPolicy::NOT_IMPLEMENTED
            std::cout << "#### COMMAND NOT IMPLEMENTED ####\n";
            return 1;
        }
    } catch (const std::exception& e) {
        std::cout << "#### ERROR ####\n";
        std::cout << e.what() << "\n";
        return 1;
    }
}
