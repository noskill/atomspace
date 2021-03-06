from libcpp cimport bool
from libcpp.vector cimport vector
from libcpp.list cimport list as cpplist
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from cython.operator cimport dereference as deref

cdef extern from "Python.h":
    # Tacky hack to pass atomspace pointer to AtomSpace ctor.
    cdef void* PyLong_AsVoidPtr(object)

    # Needed to return truth value pointers to C++ callers.
    cdef object PyLong_FromVoidPtr(void *p)

ctypedef public long PANDLE

# Basic wrapping for back_insert_iterator conversion.
cdef extern from "<vector>" namespace "std":
    cdef cppclass output_iterator "back_insert_iterator<vector<opencog::Handle> >"
    cdef output_iterator back_inserter(vector[cHandle])

# Basic OpenCog types
# NameServer
ctypedef short Type

cdef extern from "opencog/atoms/atom_types/NameServer.h" namespace "opencog":
    cdef cppclass cNameServer "opencog::NameServer":
        bint isNode(Type t)
        bint isLink(Type t)
        bint isA(Type t, Type t)

        bint isDefined(string typename)
        Type getType(string typename)
        string getTypeName(Type t)
        Type getNumberOfClasses()
    cdef cNameServer nameserver()

cdef extern from "opencog/atoms/atom_types/atom_types.h" namespace "opencog":
    cdef Type NOTYPE

# Value
cdef extern from "opencog/atoms/value/Value.h" namespace "opencog":
    cdef cppclass cValue "opencog::Value":
        Type get_type()
        bint is_atom()
        bint is_node()
        bint is_link()

        string to_string()
        string to_short_string()
        bint operator==(const cValue&)
        bint operator!=(const cValue&)

    ctypedef shared_ptr[cValue] cValuePtr "opencog::ValuePtr"

cdef class PtrHolder:
    cdef shared_ptr[void] shared_ptr
    @staticmethod
    cdef PtrHolder create(shared_ptr[void]& ptr)

cdef class Value:
    cdef PtrHolder ptr_holder
    cdef cValuePtr get_c_value_ptr(self)
    @staticmethod
    cdef Value create(cValuePtr& ptr)


# TruthValue
ctypedef double count_t
ctypedef double confidence_t
ctypedef double strength_t

cdef extern from "opencog/atoms/truthvalue/TruthValue.h" namespace "opencog":
    ctypedef shared_ptr[const cTruthValue] tv_ptr "opencog::TruthValuePtr"

    cdef cppclass cTruthValue "const opencog::TruthValue"(cValue):
        strength_t get_mean()
        confidence_t get_confidence()
        count_t get_count()
        @staticmethod
        tv_ptr DEFAULT_TV()
        bint operator==(cTruthValue h)
        bint operator!=(cTruthValue h)

cdef extern from "opencog/atoms/truthvalue/SimpleTruthValue.h" namespace "opencog":
    cdef cppclass cSimpleTruthValue "opencog::SimpleTruthValue"(cTruthValue):
        cSimpleTruthValue(double, double)
        strength_t get_mean()
        confidence_t get_confidence()
        count_t get_count()
        count_t confidenceToCount(double)
        confidence_t countToConfidence(double)
        tv_ptr DEFAULT_TV()
        string to_string()
        bint operator==(cTruthValue h)
        bint operator!=(cTruthValue h)

cdef class TruthValue(Value):
    cdef _mean(self)
    cdef _confidence(self)
    cdef _count(self)
    cdef cTruthValue* _ptr(self)
    cdef tv_ptr* _tvptr(self)


cdef extern from  "opencog/atoms/truthvalue/TTruthValue.h" namespace "opencog":
    ctypedef shared_ptr[const cTTruthValue] ttv_ptr "opencog::TTruthValuePtr"
    cdef cppclass cTTruthValue "opencog::TTruthValue"(cTruthValue):
        cTTruthValue(object)
        strength_t get_mean()
        confidence_t get_confidence()
        count_t get_count()
        #tv_ptr DEFAULT_TV()
        string to_string()
        bint operator==(cTruthValue h)
        bint operator!=(cTruthValue h)
        void * getPtr()

    cdef ttv_ptr createTTruthValue(...)



# Atom
cdef extern from "opencog/atoms/base/Link.h" namespace "opencog":
    pass

cdef extern from "opencog/atoms/base/Atom.h" namespace "opencog":
    cdef cppclass cAtom "opencog::Atom" (cValue):
        cAtom()

        output_iterator getIncomingSet(output_iterator)

        tv_ptr getTruthValue()
        void setTruthValue(tv_ptr tvp)
        void setValue(const cHandle& key, const cValuePtr& value)
        cValuePtr getValue(const cHandle& key) const

        output_iterator getIncomingSetByType(output_iterator, Type type)

        # Conditionally-valid methods. Not defined for all atoms.
        string get_name()
        vector[cHandle] getOutgoingSet()

    cdef cHandle handle_cast "HandleCast" (cValuePtr) except +

# Handle
cdef extern from "opencog/atoms/base/Handle.h" namespace "opencog":
    ctypedef shared_ptr[cAtom] cAtomPtr "opencog::AtomPtr"

    cdef cppclass cHandle "opencog::Handle" (cAtomPtr):
        cHandle()
        cHandle(const cHandle&)

        cAtom* atom_ptr()
        string to_string()
        string to_short_string()

        bint operator==(cHandle h)
        bint operator!=(cHandle h)
        bint operator<(cHandle h)
        bint operator>(cHandle h)
        bint operator<=(cHandle h)
        bint operator>=(cHandle h)
        cHandle UNDEFINED
# HandleSeq
    cdef cppclass cHandleSeq "opencog::HandleSeq"

cdef class Atom(Value):
    cdef cHandle* handle
    cdef AtomSpace atomspace
    cdef object _atom_type
    cdef object _name
    cdef object _outgoing
    cdef cHandle get_c_handle(Atom self)
    # Cython compiler complains that signature of the method should be
    # compatible with one from the parent class. It is the reason why we cannot
    # have Atom.create and Value.create at same time.
    @staticmethod
    cdef Atom createAtom(cHandle& handle, AtomSpace a)


# AtomSpace
cdef extern from "opencog/atomspace/AtomSpace.h" namespace "opencog":
    cdef cppclass cAtomSpace "opencog::AtomSpace":
        cAtomSpace()
        cAtomSpace(cAtomSpace * parent)

        cHandle add_atom(cHandle handle) except +

        cHandle add_node(Type t, string s) except +
        cHandle add_node(Type t, string s, tv_ptr tvn) except +

        cHandle add_link(Type t, vector[cHandle]) except +
        cHandle add_link(Type t, vector[cHandle], tv_ptr tvn) except +

        cHandle get_handle(Type t, string s)
        cHandle get_handle(Type t, vector[cHandle])

        cHandle set_value(cHandle h, cHandle key, cValuePtr value)
        cHandle set_truthvalue(cHandle h, tv_ptr tvn)

        bint is_valid_handle(cHandle h)
        int get_size()

        # ==== query methods ====
        # get by type
        output_iterator get_handles_by_type(output_iterator, Type t, bint subclass)

        void clear()
        bint remove_atom(cHandle h, bint recursive)


cdef AtomSpace_factory(cAtomSpace *to_wrap)

cdef class AtomSpace:
    cdef cAtomSpace *atomspace
    cdef bint owns_atomspace
    cdef object parent_atomspace


cdef create_python_value_from_c_value(const cValuePtr& value, AtomSpace atomspace)

# FloatValue
cdef extern from "opencog/atoms/value/FloatValue.h" namespace "opencog":
    cdef cppclass cFloatValue "opencog::FloatValue":
        cFloatValue(double value)
        cFloatValue(const vector[double]& values)
        const vector[double]& value() const

# StringValue
cdef extern from "opencog/atoms/value/StringValue.h" namespace "opencog":
    cdef cppclass cStringValue "opencog::StringValue":
        cStringValue(const string& value)
        cStringValue(const vector[string]& values)
        const vector[string]& value() const

# LinkValue
cdef extern from "opencog/atoms/value/LinkValue.h" namespace "opencog":
    cdef cppclass cLinkValue "opencog::LinkValue":
        cLinkValue(const vector[cValuePtr]& values)
        const vector[cValuePtr]& value() const

cdef inline bool is_in_atomspace(cAtomSpace * atomspace, cHandle h):
     cdef cAtom * atom_ptr = <cAtom*>h.get()
     if atom_ptr == NULL:  # avoid null-pointer deref
         return False
     cdef Type t
     t = deref(atom_ptr).get_type()
     if deref(atom_ptr).is_node():
         if deref(atomspace).get_handle(t, deref(atom_ptr).get_name()):
             return True
         return False
     cdef vector[cHandle] handle_vector = deref(atom_ptr).getOutgoingSet()
     if deref(atom_ptr).is_link():
         if deref(atomspace).get_handle(t, handle_vector):
             return True
         return False
     raise RuntimeError("Argument is not link and not node")

# TODO: find proper way to work with dependencies includes into atomspace.pxd
# means that we need to add these files at each library which depends on
# atomspace.pxd, see CMakeLists.txt
include "ptrvalue.pxd"
include "grounded_object_node.pxd"
