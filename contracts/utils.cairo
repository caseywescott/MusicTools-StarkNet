%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_nn, is_le, is_not_zero


//******************
// Helper Functions
//******************

@view
func abs_diff{range_check_ptr}(num1: felt, num2: felt) -> (diff: felt) {
   
    alloc_locals;
 
    local diff = is_le(num1, num2);
   
 if (diff == 1) {
        return (diff=num2-num1);
    } else {
        return (diff=num1-num2);
    }

}

@view
func find_min_inner{range_check_ptr}(
    arr_len: felt, arr: felt*, initval: felt
) -> (minval: felt) {
    alloc_locals;

    if (arr_len == 0) {
        return (minval=initval);
    }

    local diff = is_le(initval, arr[0]);
    
    local outy;

     if (diff == 1) {
        assert outy = initval;
    } else {
        assert outy = arr[0];
    }

    let (minval) = find_min_inner(
        arr_len=arr_len - 1,
        arr=arr+1,
        initval = outy
    );

    return (minval=minval);
}

@view
func find_min{range_check_ptr}(arr_len: felt, arr: felt*) -> (minval: felt) {
   
    alloc_locals;
  let initval = arr[0];
    let (min) = find_min_inner(arr_len-1, arr+1, initval);
   
return(minval=min);

}

@view
func find_min_and_index_inner{range_check_ptr}(
    arr_len: felt, arr: felt*, initval: felt, idx: felt, current_min_idx: felt 
) -> (minval: felt, idx: felt, current_min_idx: felt) {
    alloc_locals;

    if (arr_len == 0) {
        return (minval=initval, idx=idx, current_min_idx=current_min_idx);
    }

    local diff = is_le(initval, arr[0]);
    
    local outy;
    local c_min_idx;

     if (diff == 1) {
        assert outy = initval;
        assert c_min_idx = current_min_idx;
    } else {
        assert outy = arr[0];
        assert c_min_idx = idx+1;
    }

    let (minval, idx, current_min_idx) = find_min_and_index_inner(
        arr_len=arr_len - 1,
        arr=arr+1,
        initval = outy, 
        idx=idx+1,
        current_min_idx=c_min_idx
    );

    return (minval=minval, idx=idx, current_min_idx=current_min_idx);
}

@view
func find_min_and_index{range_check_ptr}(arr_len: felt, arr: felt*) -> (minval: felt, cidx: felt) {
   
    alloc_locals;
  let initval = arr[0];
    let (min, idx, cidx) = find_min_and_index_inner(arr_len-1, arr+1, initval,0, 0);
   
return(minval=min, cidx=cidx);

}