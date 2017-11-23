#! /usr/bin/env python
from setuptools import find_packages
from numpy.distutils.core import Extension
from os import listdir, path, environ
from datetime import datetime

PKG_INFO= {
    'version':environ.get(
                    'NC5NG_BUILD_VERSION',
                    int(datetime.now().timestamp())
    ),
    'description': "Python Wrapper for the NADCON5 Datum Transformation Tool",
    'long_description': """Used to Transform US National Geodetic Survey Datums USSD, NAD27, NAD83

For More Information See: https://nc5ng.org

For Documentation See: https://docs.nc5ng.org/latest
""",
    'author':"Andrey Shmakov",
    'author_email':"akshmakov@gmail.com",
    'url':"https://nc5ng.org",
    'download_url':"https://github.com/nc5ng/nadcon5ng"
}

## Selectively disable modules from processing
DISABLED_MODULES = [ 
    ]

_LINK_PLOTCOAST = " -lplotcoast "
F2PY_DEFAULT_OPTS = [ ]
MODULE_BASE_OPTS = { }
MODULE_EXTRA_OPTS = {
    'nc5ng.core.bwplotvc': [_LINK_PLOTCOAST,],
    'nc5ng.core.bwplotcv':[_LINK_PLOTCOAST,],
    'nc5ng.core.coplot': [_LINK_PLOTCOAST,],
    'nc5ng.core.coplotwcv':[_LINK_PLOTCOAST,],
}
print (MODULE_EXTRA_OPTS)
## Buffer for calculated Extensions
fortran_extensions = []

##
## Make The KWARGS aka a Dictionary
## suitable for passing to numpy.distutils.core.Extension
##
def mk_fortran_extension_kwargs(src_file, pkg, sig_dir = None):
    root, ext = path.splitext(src_file)
    src_dir, name = path.split(root)

    mod_name = ("%s.%s"%(pkg, name)).strip()

    if ext not in ['.f', '.for']:
        print (src_file, " is not a valid fortran file, ignoring ")
        return None

    if mod_name in DISABLED_MODULES:
        print (mod_name, " is explicitly disabled in setup.py , ignoring ")
        return None

    sig_file_name = name + ".pyf"
    sig_file = None

    f2py_e_opts = MODULE_EXTRA_OPTS.get( mod_name, [])
    f2py_b_opts = MODULE_BASE_OPTS.get( mod_name, F2PY_DEFAULT_OPTS)
    f2py_opts = f2py_b_opts + f2py_e_opts

    print ("Found Valid src_file ", src_file, " for package ", pkg,
           " , with sig_dir ", sig_dir, " module name ", mod_name, " f2py_opts ", f2py_opts)

    sources = [ src_file ]
    
    if sig_dir and path.exists(path.join(sig_dir, sig_file_name)):
        sig_file = path.join(sig_dir, sig_file_name)
        print ("Found signature file ", sig_file)
    elif path.exists(path.join(src_dir, sig_file_name)):
        sig_file = path.join(src_dir, sig_file_name)
        print ("Found signature file ", sig_file)

    if sig_file is not None:
        sources = [ sig_file, src_file ]

    return {'name': mod_name,
            'sources' : sources,
            'f2py_options' : f2py_opts}
            
## Setup Our Core Library Fortran Extension
    
CORE_PKG = 'nc5ng.core'
CORE_SRC_DIR = 'src/Subs'
CORE_PKG_DIR = 'nc5ng/core'
CORE_PROGRAMS = [mk_fortran_extension_kwargs(path.join(CORE_SRC_DIR, f),
                                             CORE_PKG,
                                             CORE_PKG_DIR)
                 for f in listdir(CORE_SRC_DIR)]


## Run Through All Extensions
for kwargs in CORE_PROGRAMS:
    if kwargs is not None:
        fortran_extensions.append(Extension(**kwargs))


## Run Setup 
if __name__ == '__main__':
    from numpy.distutils.core import setup

    print (fortran_extensions)
    
    setup(name = 'nc5ng',
          packages = find_packages(),
          ext_modules = fortran_extensions,
          **PKG_INFO
          )
          
    #setup(**configuration(top_path='').todict())
