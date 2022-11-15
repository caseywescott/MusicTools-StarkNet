%lang starknet
from starkware.cairo.common.alloc import alloc

//*****************************************************************************************************
// Sequencable Collections 
//*****************************************************************************************************


// Create Geometric Series
// Useful for musical Accelerandos/Deccelerandos (speeding-up/slowing down)

@view
func geom_array_fill{range_check_ptr}(
    arr_len: felt, arr: felt*, grow_rate: felt, initval: felt, arr_size: felt
) -> () {
    alloc_locals;

    if (arr_size == 0) {
        return ();
    }
    let val = initval+grow_rate; 
    assert arr[arr_len] = val;

    geom_array_fill(
        arr_len=arr_len + 1,
        arr=arr,
        grow_rate=grow_rate+1,
        initval=val, 
        arr_size=arr_size-1
    );

    return ();
}

// Create Geometric Series and differentiate values 
// Useful for for creating notes for Accelerandos/Deccelerandos that play until the next note

@view
func geom_array_diff_fill{range_check_ptr}(
    arr_len: felt, arr: felt*, diff_arr_len: felt, diff_arr: felt*, grow_rate: felt, initval: felt, arr_size: felt
) -> () {
    alloc_locals;

    if (arr_size == 0) {
        return ();
    }
    let val = initval+grow_rate; 
    assert arr[arr_len] = val;
    assert diff_arr[arr_len] = grow_rate;

    geom_array_diff_fill(
        arr_len=arr_len + 1,
        arr=arr,
        diff_arr_len=diff_arr_len+1,
        diff_arr=diff_arr,
        grow_rate=grow_rate+1,
        initval=val, 
        arr_size=arr_size-1
    );

    return ();
}

// Create Array of arr_size with initval 
// Useful for creating a base pulse/rhythm/Pedal-Point etc

@view
func array_fill{range_check_ptr}(
    arr_len: felt, arr: felt*, inc: felt, initval: felt, arr_size: felt
) -> () {
    alloc_locals;

    if (arr_size == 0) {
        return ();
    }
    let val = initval+inc; 
    assert arr[arr_len] = val;

    array_fill(
        arr_len=arr_len + 1,
        arr=arr,
        inc=inc+1,
        initval=val, 
        arr_size=arr_size-1
    );

    return ();
}


@view
func copy_array{range_check_ptr}(
    arr_len: felt, arr: felt*, new_arr_len: felt, new_arr: felt*, idx: felt
) {
    alloc_locals;

    if (arr_len == idx) {
        return ();
    }

    assert new_arr[new_arr_len] = arr[idx];

    copy_array(
        arr_len=arr_len,
        arr=arr,
        new_arr_len=new_arr_len+1,
        new_arr=new_arr,
        idx=idx+1 
    );

    return ();
}

// Useful for creating note Scores 

@view
func append_arr{range_check_ptr}(
    arr_len: felt, arr: felt*, arr2_len: felt, arr2: felt*
) -> () {

    alloc_locals;

    if (arr2_len == 0) {
        return ();
    }

    assert arr[arr_len] = arr2[0];  

    append_arr(
        arr_len=arr_len+1,
        arr=arr,
        arr2_len=arr2_len-1,
        arr2=arr2+1
    );

    return ();
}

// Retrograde set operation 
// Useful for melodic/rhythmic variation

@view
func reverse_arr{range_check_ptr}(
    arr_len: felt, arr: felt*, arr2_len: felt, arr2: felt*, idx: felt
) -> () {

    alloc_locals;

    let outsize = arr_len+arr2_len;

    if (idx == arr_len) {
        return ();
    }

    assert arr2[idx] = arr[arr_len - 1 - idx]; 

    reverse_arr(
        arr_len=arr_len,
        arr=arr,
        arr2_len=arr2_len+1,
        arr2=arr2,
        idx=idx+1
    );

    return ();
}

@view
func remove_item_from_array{range_check_ptr}(
    arr_len: felt, arr: felt*, new_arr_len: felt, new_arr: felt*, idx: felt, item
) {
    alloc_locals;

    if (arr_len == idx) {
        return ();
    }
    local val;

    if(arr[idx]==item){
    val =0;
    }else{
     val =1;
    assert new_arr[new_arr_len] = arr[idx];
}

    remove_item_from_array(
        arr_len=arr_len,
        arr=arr,
        new_arr_len=new_arr_len+val,
        new_arr=new_arr,
        idx=idx+1,
        item=item 
    );

    return ();
}
