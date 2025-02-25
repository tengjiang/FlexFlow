#pragma once

#include "flexflow/parallel_tensor.h"

namespace FlexFlow {

struct ReduceParams {
  std::vector<int> axes;
  bool keepdims;
  bool is_valid(ParallelTensorShape const &) const;
};

bool operator==(ReduceParams const &, ReduceParams const &);

} // namespace FlexFlow

namespace std {
template <>
struct hash<FlexFlow::ReduceParams> {
  size_t operator()(FlexFlow::ReduceParams const &) const;
};
} // namespace std
