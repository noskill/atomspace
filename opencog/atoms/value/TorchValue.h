#ifndef _OPENCOG_TORCH_VALUE_H
#define _OPENCOG_TORCH_VALUE_H


#include <opencog/atoms/value/Value.h>
#include <opencog/atoms/atom_types/atom_types.h>
#include <torch/torch.h>

namespace opencog
{

class TorchValue:
    public at::Tensor,
    public Value
{
public:
    TorchValue(at::Tensor t_value):
        at::Tensor(t_value),
        Value(TORCH_VALUE) {};
     bool operator==(const Value& other) const;
     virtual std::string to_string(const std::string& indent) const;

};


template<typename ... Type>
static inline std::shared_ptr<TorchValue> createTorchValue(Type&&... args) {
    return std::make_shared<TorchValue>(std::forward<Type>(args)...);
}

} // namespace
#endif
