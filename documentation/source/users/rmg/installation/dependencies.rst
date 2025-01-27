.. _dependencies:

************
Dependencies
************


List of Dependencies
====================

Briefly, RMG depends on the following packages, almost all of which can be found in the `RMG anaconda channel <https://anaconda.org/rmg>`_ as binary packages.


* **boost:** portable C++ source libraries
* **cairo:** a 2D vector graphics library with support for multiple backends including image buffers, PNG, PostScript, PDF, and SVG file output.  Used for molecular diagram generation
* **cairocffi:** a set of Python bindings and object-oriented API for cairo
* **coverage:** code coverage measurement for Python
* **cython:** compiling Python modules to C for speed up
* **dde:** Data Driven Estimator for neural network thermochemistry prediction
* **ffmpeg:** (optional) used to encode videos, necessary for generating video flux diagrams
* **gaussian:** (optional) commerical software program for quantum mechanical calculations.  Must be installed separately.
* **gcc:** GNU compiler collection for C,C++, and Fortran. (MinGW is used in windows)
* **gprof2dot:** converts Python profiling output to a dot graph
* **graphviz:** generating flux diagrams
* **jinja2:** Python templating language for html rendering
* **jupyter:** (optional) for using IPython notebooks
* **lpsolve:** mixed integer linear programming solver, used for resonance structure generation. Must also install Python extension.
* **markupsafe:** implements XML/HTML/XHTML markup safe strings for Python
* **matplotlib:** library for making plots
* **mock:** for unit-testing
* **mopac:** semi-empirical software package for QM calculations
* **mpmath:** for arbitrary-precision arithmetic used in Arkane
* **muq:** (optional) MIT Uncertainty Quantification library, used for global uncertainty analysis
* **networkx:** (optional) network analysis for reaction-path analysis IPython notebook
* **nose:** advanced unit test controls
* **numpy:** fast matrix operations
* **openbabel:** chemical toolbox for speaking the many languages of chemical data
* **psutil:** system utilization diagnostic tool
* **pydas:** differential algebraic system solver
* **pydot:** interface to Dot graph language
* **pydqed:** constrained nonlinear optimization
* **pyparsing:** a general parsing module for python
* **pyrdl:** RingDecomposerLib for graph ring perception
* **pyyaml:** Python framework for YAML
* **pyzmq:** Python bindings for zeroMQ
* **quantities:** unit conversion
* **rdkit:** open-source cheminformatics toolkit
* **scipy:** fast mathematical toolkit
* **setuptools:** for packaging Python projects
* **sphinx:** documentation generation
* **symmetry:** calculating symmetry numbers of chemical point groups
* **xlwt:** generating Excel output files

.. _dependenciesRestrictions:

License Restrictions on Dependencies
====================================

All of RMG's dependencies except the ones listed below are freely available and compatible with RMG's open source MIT license (though the specific nature of their licenses vary). 

* **pydas**: The DAE solvers used in the simulations come from `Linda Petzold’s research group <https://cse.cs.ucsb.edu/software/>`_ at UCSB.  For running sensitivity analysis in RMG, the DASPK 3.1 solver is required, which "is subject to copyright restrictions” for non-academic use. Please visit their website for more details. To run RMG without this restriction, one may switch to compiling with the DASSL solver instead in RMG, which is "available in the public domain.”

If you wish to do on-the-fly quantum chemistry calculations of thermochemistry (advisable for fused cyclic species in particular, where the ring corrections to group additive estimates are lacking),
the then you will need the third-party software for the QM calculations:

* **gaussian**: Gaussian03 and Gaussian09 are currently supported and commercially available.  See `https://gaussian.com <https://gaussian.com>`_ for more details.
