#include <opencog/util/exceptions.h>
#include <opencog/atoms/value/TorchValue.h>
#include <opencog/atoms/value/ValueFactory.h>

using namespace opencog;

bool TorchValue::operator==(const Value& other) const
{
    return (&other)==this;
}

std::string TorchValue::to_string(const std::string& indent) const {
    return this->toString();
}

