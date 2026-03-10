#!/bin/bash
# Post-buildout fixups for the circa-be (envcoord) instances.
# Run this after each buildout.
#
# Products.CMFPlone is a transitive dependency:
#   pas.plugins.ldap -> yafowil.plone -> Products.CMFPlone
# We KEEP the egg (Python imports need it) but EXCLUDE its ZCML
# so that its AppTraverser and Plone views don't get registered.

# Register pas.plugins.ldap and exclude problematic ZCML packages.
# This file is loaded from package-includes BEFORE five:loadProducts,
# so the excludes take effect before Zope auto-discovers Products.*.
for pkg_dir in parts/*/etc/package-includes; do
    if [ -d "$pkg_dir" ]; then
        cat > "$pkg_dir/016.5-pas.plugins.ldap-configure.zcml" << 'ZCML'
<configure xmlns="http://namespaces.zope.org/zope"
           xmlns:zcml="http://namespaces.zope.org/zcml">
  <configure zcml:condition="installed Products.CMFPlone">
    <exclude package="Products.CMFPlone" />
  </configure>
  <configure zcml:condition="installed pas.plugins.ldap">
    <include package="pas.plugins.ldap" />
  </configure>
</configure>
ZCML
        echo "Added pas.plugins.ldap ZCML to $pkg_dir"

        # Circa-specific overrides: CSRF + yafowil widget resources
        cat > "$pkg_dir/999-additional-overrides.zcml" << 'ZCML'
<configure xmlns="http://namespaces.zope.org/zope"
           xmlns:browser="http://namespaces.zope.org/browser">

<!-- Disable plone.protect CSRF auto-protection (not needed for Naaya) -->
<adapter
    factory="Products.NaayaCore.nocsrf.NoOpTransform"
    name="plone.protect.autocsrf"
    />

<!-- Yafowil widget resources for pas.plugins.ldap manage page.
     The standard yafowil.plone views require CMFPlone/plone.registry
     which are not available in Naaya. These serve the JS/CSS directly. -->
<browser:page
    for="*"
    name="yafowil.plone.js"
    class="naaya.groupware.yafowil_resources.YafowilJS"
    permission="zope2.View"
    />
<browser:page
    for="*"
    name="yafowil.plone.css"
    class="naaya.groupware.yafowil_resources.YafowilCSS"
    permission="zope2.View"
    />

</configure>
ZCML
        echo "Created circa overrides at $pkg_dir"
    fi
done
