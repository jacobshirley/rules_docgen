"https://github.com/aspect-build/rules_lint/blob/main/docs/linting.md"
load("@aspect_rules_lint//lint:vale.bzl", "lint_vale_aspect")

vale = lint_vale_aspect(
    # TODO: visit markdown() rules
    # This rule has attribute 'file' rather than 'srcs' which rules_lint doesn't allow.
    # rule_kinds = ["markdown"],
    binary = Label(":vale"),
    config = Label("//:.vale.ini"),
)
