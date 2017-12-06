__path__ = __import__('pkgutil').extend_path(__path__, __name__)

# This is required to fill-in the nc5ng namespace
# The source in this folder only creates the core utilities
# Other projects provide additional subpakcages in nc5ng.*

