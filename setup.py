from setuptools import find_packages
from numpy.distutils.core import Extension
from os import listdir, path

DISABLED_MODULES = [ 'nc5ng.tools.regrd2' ,
                     'nc5ng.tools.b2xyz',
                     'nc5ng.tools.xyz2b' ,
                     'nc5ng.makeplotfiles02',
                     'nc5ng.makeplotfiles03']


fortran_extensions = []


def mk_fortran_extension_kwargs(src_file, pkg, sig_dir = None):
    root, ext = path.splitext(src_file)
    src_dir, name = path.split(root)

    mod_name = "%s.%s"%(pkg, name)

    if ext not in ['.f', '.for']:
        print (src_file, " is not a valid fortran file, ignoring ")
        return None

    if mod_name in DISABLED_MODULES:
        print (mod_name, " is explicitly disabled in setup.py , ignoring ")
        return None

    sig_file_name = name + ".pyf"
    sig_file = None

    print ("Found Valid src_file ", src_file, " for package ", pkg,
           " , with sig_dir ", sig_dir)

    if sig_dir and path.exists(path.join(sig_dir, sig_file_name)):
        sig_file = path.join(sig_dir, sig_file_name)
    elif path.exists(path.join(src_dir, sig_file_name)):
        sig_file = path.join(src_dir, sig_file_name)

    if sig_file is not None:
        return {'name': mod_name,
                'sources' : [ sig_file, src_file]}
    else:
        print( "No Signature File Found for " , name )
        return {'name': mod_name,
                'sources' : [ src_file  ]}
            

ROOT_PKG = 'nc5ng'
ROOT_SRC_DIR = 'src'
ROOT_PKG_DIR = 'nc5ng'
ROOT_PROGRAMS = [mk_fortran_extension_kwargs(path.join(ROOT_SRC_DIR, f),
                                             ROOT_PKG,
                                             ROOT_PKG_DIR)
                 for f in listdir(ROOT_SRC_DIR)]

UTILS_PKG = 'nc5ng.utils'
UTILS_SRC_DIR = 'src/Subs'
UTILS_PKG_DIR = 'nc5ng/utils'
UTILS = [mk_fortran_extension_kwargs(path.join(UTILS_SRC_DIR, f),
                                     UTILS_PKG,
                                     UTILS_PKG_DIR)
         for f in listdir(UTILS_SRC_DIR)]

TOOLS_PKG = 'nc5ng.tools'
TOOLS_SRC_DIR = 'src/BinSource'
TOOLS_PKG_DIR = 'nc5ng/tools'
TOOLS = [mk_fortran_extension_kwargs(path.join(TOOLS_SRC_DIR, f),
                                     TOOLS_PKG,
                                             TOOLS_PKG_DIR)
         for f in listdir(TOOLS_SRC_DIR)]




for kwargs in UTILS+TOOLS+ROOT_PROGRAMS:
    
    if kwargs is not None:
        fortran_extensions.append(Extension(**kwargs))

    
if __name__ == '__main__':
    from numpy.distutils.core import setup
    setup(name = 'nc5ng',
          description = "nc5ng",
          packages = find_packages(),
          ext_modules = fortran_extensions
          )
          
    #setup(**configuration(top_path='').todict())
