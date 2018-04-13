# -*- coding: utf-8 -*-
"""
Utilities for deploying Django applications with Paste Deploy.
"""


def app_factory(global_config, django_wsgi_application):
    """
    Paste app factory that imports and returns the given WSGI applicaton.

    Args:
        global_config: The global paste configuration
        django_wsgi_application: The wsgi application to deploy as a dotted path

    Returns:
        The WSGI application.
    """
    from django.utils.module_loading import import_string
    return import_string(django_wsgi_application)
