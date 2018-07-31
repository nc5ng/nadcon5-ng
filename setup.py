#! /usr/bin/env python
from setuptools import setup
from numpy.distutils.core import Extension
from distutils.command.build   import build as DistutilsBuild
from distutils.command.install import install as DistutilsInstall
from os import listdir, path, environ, walk
from datetime import datetime
import subprocess


from numpy.distutils.core import Extension, setup

# Development version is datetime + optional git hash
VERSION = environ.get('NC5NG_VERSION')
LOG_LEVEL = int(environ.get('NC5NG_DEBUG',3))
LOG_DEBUG = 5
LOG_INFO = 4
LOG_WARNING = 3
LOG_ERROR = 2
LOG_FAIL = 1
LOG_ALL = 0

def log (level, *msg):
    if level < LOG_LEVEL:
        print(*msg)

if not VERSION:
    VERSION="0.0.3"
    """
    now = datetime.now()
    VERSION="%s%s%s+%s%s"%(now.year, now.month, now.day, now.hour, now.minute)

    root_dir = path.abspath(path.dirname(__file__))
    if path.exists(path.join(root_dir, '.git')):
        cmd = ['git', 'rev-parse', '--verify', '--short', 'HEAD']
        git_hash = subprocess.check_output(cmd).decode().strip()
        VERSION = "%s.%s"%(git_hash, VERSION)

    """

    
               


PKG_INFO= {
    'version':VERSION,
    'description': "Python Package and Wrapper for the NADCON5 Datum Transformation Data and Utilities",
    'long_description': """Used to Generate and analyze Transformations of  US National Geodetic Survey Datums USSD, NAD27, and NAD83, and various other realizations. 

For More Information See: https://nc5ng.org

For Documentation See: https://docs.nc5ng.org/latest
""",
    'author':"Andrey Shmakov",
    'author_email':"akshmakov@gmail.com",
    'url':"https://nc5ng.org",
    'download_url':"https://github.com/nc5ng/nadcon5-ng",
    'install_requires':[
        'fortranformat',
        ],
}

## Selectively disable modules from processing
## List Fortran Files not intended for Build Here
DISABLED_MODULES = [ 
    ]

## Default Options for F2PY Invocation
F2PY_DEFAULT_OPTS = { "include_dirs" : ["src/Subs"] }

## Module Specific Includes
MODULE_INCLUDES = {
    'nc5ng.core.bwplotvc': ['src/Subs/plotcoast.f'],
    'nc5ng.core.bwplotcv': ['src/Subs/plotcoast.f'],
    'nc5ng.core.coplot': ['src/Subs/plotcoast.f'],
    'nc5ng.core.coplotwcv': ['src/Subs/plotcoast.f'],
    'nc5ng.core.gridstats' : ['src/Subs/select2_dbl.for']
    }

## Module Specific Options
MODULE_OPTS = {
    'nc5ng.core.bwplotvc': {}, # { 'library_dirs' : ['build/lib'],
                             #'libraries': ['plotcoast' ]},
    'nc5ng.core.bwplotcv':{},
    'nc5ng.core.coplot': {},
    'nc5ng.core.coplotwcv': {},
}


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
    """ Create kwargs for the given fortran extension
    \param src_file the name of the source file to be built
    \param pkg the root package that will be built
    \param sig_dir directory containing signature file
    \return dictionary containing KWARGS
    """
        
    root, ext = path.splitext(src_file)
    src_dir, name = path.split(root)

    mod_name = ("%s.%s"%(pkg, name)).strip()

    if ext not in ['.f', '.for']:
        log (LOG_WARNING,src_file, " is not a valid fortran file, ignoring ")
        return None

    if mod_name in DISABLED_MODULES:
        log (LOG_WARNING, mod_name, " is explicitly disabled in setup.py , ignoring ")
        return None

    sig_file_name = name + ".pyf"
    sig_file = None

    f2py_opts = MODULE_OPTS.get( mod_name, F2PY_DEFAULT_OPTS )

    log (LOG_INFO, "Found Valid src_file ", src_file, " for package ", pkg,
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


def package_files(directory):
    paths = []
    for (pth, directories, filenames) in walk(directory):
        for filename in filenames:
            paths.append(path.join( pth, filename))
    return paths

## Setup Constants for our packages
ROOT_PKG = 'nc5ng'
    
CORE_PKG = 'nc5ng.core'
CORE_SRC_DIR = 'src/Subs'
CORE_PKG_DIR = 'nc5ng/nc5core'
CORE_PROGRAMS = [mk_fortran_extension_kwargs(path.join(CORE_SRC_DIR, f),
                                             CORE_PKG,
                                             CORE_PKG_DIR)
                 for f in listdir(CORE_SRC_DIR)]


DATA_PKG = 'nc5ng.nc5data'
DATA_PKG_DIR = 'nc5ng/nc5data'
DATA_PKG_DATA_DIR = "data"
DATA_PKG_DATA_FILES = package_files(DATA_PKG_DATA_DIR)
print (DATA_PKG_DATA_FILES)


BUILD_PKG = 'nc5ng.nc5build'
BUILD_PKG_DIR = 'nc5ng/nc5build'


PACKAGES = [ROOT_PKG, CORE_PKG, DATA_PKG]#, BUILD_PKG]


## Run Setup 
if __name__ == '__main__':
    fortran_extensions = []

    ## Run Through All Extensions
    for kwargs in CORE_PROGRAMS:
        if kwargs is not None:
            fortran_extensions.append(Extension(**kwargs))
    
    setup(name = 'nc5ng-core',
          packages = PACKAGES,
          package_dir={'nc5ng.nc5data': 'nc5ng/nc5data'},
          package_data={'nc5ng.nc5data': DATA_PKG_DATA_FILES},
          ext_modules = fortran_extensions,
          **PKG_INFO
          )
          
    #setup(**configuration(top_path='').todict())
