from opencog.atomspace import TTruthValue
from opencog.atomspace import AtomSpace, types
from opencog.utilities import initialize_opencog, finalize_opencog
from opencog.type_constructors import *
import torch


a = AtomSpace()
initialize_opencog(a)

v= TTruthValue(0.4, 0.5)

print(v)


c = ConceptNode('c')
c.tv = v

t = torch.Tensor([0.2, 0.2])
print(t + v)
print(v + t)
