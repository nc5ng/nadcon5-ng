#! /usr/bin/env python
from setuptools import find_packages, setup
from distutils.command.build   import build as DistutilsBuild
from distutils.command.install import install as DistutilsInstall
from os import listdir, path, environ
from datetime import datetime


PKG_INFO= {
    'version':'0.0.2',
    'description': "Python Wrapper for the NADCON5 Datum Transformation Tool",
    'long_description': """Used to Transform US National Geodetic Survey Datums USSD, NAD27, NAD83

For More Information See: https://nc5ng.org

For Documentation See: https://docs.nc5ng.org/latest
""",
    'author':"Andrey Shmakov",
    'author_email':"akshmakov@gmail.com",
    'url':"https://nc5ng.org",
    'download_url':"https://github.com/nc5ng/nadcon5ng",
}

## Selectively disable modules from processing
DISABLED_MODULES = [ 
    ]

F2PY_DEFAULT_OPTS = { "include_dirs" : ["src/Subs"] }
MODULE_INCLUDES = {
    'nc5ng.core.bwplotvc': ['src/Subs/plotcoast.f'],
    'nc5ng.core.bwplotcv': ['src/Subs/plotcoast.f'],
    'nc5ng.core.coplot': ['src/Subs/plotcoast.f'],
    'nc5ng.core.coplotwcv': ['src/Subs/plotcoast.f'],
    'nc5ng.core.gridstats' : ['src/Subs/select2_dbl.for']
    }

MODULE_OPTS = {
    'nc5ng.core.bwplotvc': {}, # { 'library_dirs' : ['build/lib'],
                             #'libraries': ['plotcoast' ]},
    'nc5ng.core.bwplotcv':{},
    'nc5ng.core.coplot': {},
    'nc5ng.core.coplotwcv': {},
}
## Buffer for calculated Extensions
fortran_extensions = []

class MakeBuilder(DistutilsBuild):
    def run(self):
        DistutilsBuild.run(self)

def _merge_dict(x,y):
    z = x.copy()
    z.update(y)
    return z

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

    f2py_opts = MODULE_OPTS.get( mod_name, F2PY_DEFAULT_OPTS )

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

    sources = MODULE_INCLUDES.get( mod_name , []) + sources

    return _merge_dict({'name': mod_name,
                        'sources' : sources}
                       , f2py_opts)
            
## Setup Our Core Library Fortran Extension
    
CORE_PKG = 'nc5ng.core'
CORE_SRC_DIR = 'src/Subs'
CORE_PKG_DIR = 'nc5ng/core'
CORE_PROGRAMS = [mk_fortran_extension_kwargs(path.join(CORE_SRC_DIR, f),
                                             CORE_PKG,
                                             CORE_PKG_DIR)
                 for f in listdir(CORE_SRC_DIR)]





        


## Run Setup 
if __name__ == '__main__':
    from numpy.distutils.core import Extension, setup

    ## Run Through All Extensions
    for kwargs in CORE_PROGRAMS:
        if kwargs is not None:
            fortran_extensions.append(Extension(**kwargs))
    
    setup(name = 'nc5ng',
          packages = find_packages(),
          ext_modules = fortran_extensions,
          **PKG_INFO
          )
          
    #setup(**configuration(top_path='').todict())
