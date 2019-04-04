#include <torch/torch.h>
#include <opencog/atoms/value/TorchValue.h>


namespace py = pybind11;

PYBIND11_MODULE(TORCH_EXTENSION_NAME, m) {
    py::class_<opencog::TorchValue>(m, "TorchValue")
        .def(py::init<at::Tensor>());
}

