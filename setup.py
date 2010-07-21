
#!/usr/bin/env python

from distutils.core import setup
from distutils.extension import Extension
from Pyrex.Distutils import build_ext
import commands
import glob, sys

def pkgconfig(*packages, **kw):

    flag_map = {'-I': 'include_dirs', '-L': 'library_dirs', '-l': 'libraries'}
    for token in commands.getoutput("pkg-config --libs --cflags %s" % ' '.join(packages)).split():
        if flag_map.has_key(token[:2]):
            kw.setdefault(flag_map.get(token[:2]), []).append(token[2:])
        else: # throw others to extra_link_args
            kw.setdefault('extra_link_args', []).append(token)
    for k, v in kw.iteritems(): # remove duplicated
            kw[k] = list(set(v))
    return kw

setup(
    name = "python-corosync-ng",
    version = '0.0.1',
    description = 'Corosync NG bindings for Python',
    author = 'Boris Manojlovic',
    author_email = 'boris@steki.net',
    url = 'http://djule.org',
    license = 'GPL',
    classifiers = ['Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python'],
    package_dir = {'': 'lib'},
    packages = ['corosync'],
    ext_modules = [
        Extension('corosync.libcpg', ['lib/corosync/libcpg.pyx'], **pkgconfig('libcpg'))],
    cmdclass = {"build_ext": build_ext}
)
