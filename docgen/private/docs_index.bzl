"""Core documentation index processing rules."""

load(":docs.bzl", "docs")

def docs_index(
        name = "docs",
        title = None,
        entry = None,
        nav = {},
        **kwargs):
    """Create a nested navigation structure for organizing documentation.

    This macro creates a documentation index that can be referenced in the nav structure
    of other docs targets. It allows building hierarchical navigation without duplicating
    entries.

    Args:
        name: Name of the index target. Defaults to "docs".
        title: Title of the navigation section. This will be used as the display text
            when referenced with an empty string in a parent nav dictionary.
        entry: Optional entry point file for the index. If provided, clicking the index
            will navigate to this file.
        nav: Navigation structure dictionary for this section. Same format as docs() nav:
            - "path/to/file.md": "Display Name" for markdown files
            - ":link_target": "Display Name" for docs_link targets
            - ":docs_target": "Display Name" for other docs targets
            - ":index_target": "" for nested docs_index targets
        **kwargs: Additional arguments passed to the underlying docs_action rule.
    """
    docs(
        name = name,
        title = title,
        entry = entry,
        nav = nav,
        is_index = True,
        **kwargs
    )
