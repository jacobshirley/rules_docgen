"""Providers for documentation rules."""

DocsProviderInfo = provider(
    doc = "Provider to specify docs information, such as files and navigation title",
    fields = {
        "path": "The path of the documentation",
        "title": "The title of the navigation element",
        "entrypoint": "The entrypoint file for the documentation",
        "files": "The files that are part of the documentation",
        "nav": "The sub navigation elements",
    },
)

DocsLinkInfo = provider(
    doc = "Provider to specify a link to docs (external URL or internal path)",
    fields = {
        "path": "The path of the documentation",
        "title": "The title of the navigation element",
        "url": "The URL of the navigation element",
        "entrypoint": "The entrypoint file for the documentation",
        "files": "The files that are part of the documentation",
    },
)
