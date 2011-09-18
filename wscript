#! /usr/bin/env python
# encoding: utf-8
# Copyright © 2011 Jacques-Pascal Deplaix

APPNAME = 'sleepy'
VERSION = '0.1.0'

top = '.'
out = 'build'

import waflib

def options(opt):
    opt.load(['compiler_c', 'vala'])

    opt.add_option('--debug',
                   help = 'Debug mode',
                   action = 'store_true',
                   default = False)

    opt.add_option('--with-gtk3',
                   help = 'Compile with Gtk 3.0 instead of Gtk 2.0 (Experimental mode).'
                   ' Works only with Vala >= 0.13.2',
                   action = 'store_true',
                   default = False)

    opt.add_option('--disable-nls',
                   help = 'Disable internationalisation (text in english).',
                   action = 'store_true',
                   default = False)
                   
    opt.add_option('--with-appindicator',
                   help = 'Compile with AppIndicator support.',
                   action = 'store_true',
                   default = False)
                   
def configure(conf):
    conf.env.CFLAGS = list()
    conf.env.VALAFLAGS = list()
    conf.env.LINKFLAGS = list()

    conf.load(['compiler_c', 'gnu_dirs'])

    if conf.options.disable_nls != True:
        conf.load(['intltool'])

    if conf.options.with_gtk3 == True:
        conf.env.VALAFLAGS.extend(['--define=GTK3'])

    conf.load('vala', funs = '')
    conf.check_vala(min_version = conf.options.with_gtk3 and (0, 13, 2) or (0, 10, 0))

    if conf.env.VALAC_VERSION >= (0, 12, 1):
        conf.env.VALAFLAGS.extend(['--define=VALAC_SUP_0_12_1'])
    conf.define('APPNAME',APPNAME)
    conf.define('APPLONGNAME', 'Sleep Timer')

    glib_package_version = conf.env.VALAC_VERSION >= (0, 12, 0) and '2.16.0' or '2.14.0'
    gtk_package_name = conf.options.with_gtk3 and 'gtk+-3.0' or 'gtk+-2.0'

    #vte_package_name = conf.options.with_gtk3 and 'vte-2.90' or 'vte'

    if conf.options.with_appindicator == True:
        appindicator_package_name = conf.options.with_gtk3 and 'appindicator3-0.1' or 'appindicator-0.1'
        conf.check_cfg(
            package         = appindicator_package_name,
            uselib_store    = 'APPINDICATOR',
            atleast_version = '0.3.0',
            args            = '--cflags --libs')
        conf.env.VALAFLAGS.extend(['--define=WITH_APPINDICATOR'])

    conf.check_cfg(
        package         = 'glib-2.0',
        uselib_store    = 'GLIB',
        atleast_version = glib_package_version,
        args            = '--cflags --libs')

    conf.check_cfg(
        package         = 'gobject-2.0',
        uselib_store    = 'GOBJECT',
        atleast_version = glib_package_version,
        args            = '--cflags --libs')
        

    conf.check_cfg(
        package         = gtk_package_name,
        uselib_store    = 'GTK',
        atleast_version = '2.16',
        args            = '--cflags --libs')

    """
    conf.check_cfg(
        package         = 'gee-1.0',
        uselib_store    = 'GEE',
        atleast_version = '0.1',
        args            = '--cflags --libs')        
    """ 
       
    conf.check_cfg(
        package         = 'libnotify',
        uselib_store    = 'NOTIFY',
        atleast_version = '0.1',
        args            = '--cflags --libs')               

    # Add /usr/local/include for compilation under OpenBSD
    conf.env.CFLAGS.extend(['-pipe', '-I/usr/local/include', '-include', 'config.h'])
    conf.define('VERSION', VERSION)

    if conf.options.disable_nls == False:
        conf.define('GETTEXT_PACKAGE', APPNAME)
        conf.env.VALAFLAGS.extend(['--define=ENABLE_NLS'])

    if conf.options.debug == True:
        conf.env.CFLAGS.extend(['-g3', '-ggdb3'])
        conf.env.VALAFLAGS.extend(['-g', '--define=DEBUG'])
    else:
        conf.env.CFLAGS.extend(['-O2'])
        #conf.env.VALAFLAGS.extend(['--thread'])
        conf.env.LINKFLAGS.extend(['-Wl,-O1', '-s'])

    conf.env.debug = conf.options.debug
    conf.env.with_gtk3 = conf.options.with_gtk3
    conf.env.disable_nls = conf.options.disable_nls

    conf.write_config_header('config.h')

def build(bld):
    if bld.env.disable_nls == False:
        bld(features = 'intltool_po', appname = APPNAME, podir = 'po')
        
    _packages      = ['libnotify','gee-1.0','config','posix']
    _packages.append(bld.options.with_gtk3 and 'gtk+-3.0' or 'gtk+-2.0')
    _uselib = ['GLIB', 'GOBJECT', 'GTK', 'NOTIFY']
    if bld.env.with_appindicator == True:
        _packages.append(bld.options.with_gtk3 and 'appindicator3-0.1' or 'appindicator-0.1')
        _uselib.append('APPINDICATOR')

    bld.program(
		packages = _packages,
        vapi_dirs     = 'vapi',
        target        = APPNAME,
        uselib        = _uselib,
        source        = ['src/main.vala',
                         'src/sleeptimer.vala',
                         'src/wizard.vala',
                         'src/trayicon.vala'])

def dist(ctx):
    ctx.excl = '**/.*'
