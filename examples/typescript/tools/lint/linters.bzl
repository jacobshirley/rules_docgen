"https://github.com/aspect-build/rules_lint/blob/main/docs/linting.md"

load("@aspect_rules_lint//lint:vale.bzl", "lint_vale_aspect")

vale = lint_vale_aspect(
    binary = Label(":vale"),
    config = Label("//:.vale.ini"),
)
