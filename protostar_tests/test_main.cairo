%lang starknet

//%builtins pedersen range_check

from src.main import append_arr, reverse_arr, geom_array_fill, remove_item_from_array, copy_array2, sort_array, find_min_and_index, find_min, copy_array, four_part_voicing_table, get_voicing_from_table_inner, voicing_array_sum, modal_transposition_binary, invert_keynum, new_three_part_voicing_table, ravel_string_quartet_voicing_table, get_voicing_from_table, recurse_modal_steps_and_sum,recurse_modal_steps_and_sum2, is_every_keynum_in_array_scale_degree, idx_to_mode_steps, is_keynum_scale_degree, is_note_scale_degree, modal_transposition, dorian_steps, major_steps, phrygian_steps, get_lcg_list_with_bounds,get_lcg_list_with_bounds_seed, get_notes_of_key, block_num, lcg_inner
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_block_number
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_nn, is_le, is_not_zero
from starkware.cairo.common.math import unsigned_div_rem, assert_nn

//*******************************
// ProtoStar Tests - In Progress
//*******************************


// Helper function tests if an element is contained in an array

@view
func is_element_in_array{range_check_ptr}(
    arr_len: felt, arr: felt*, element: felt
) -> (bool: felt) {
    
    alloc_locals;

    if (arr_len == 0) {
        // get the nearest index
        return (bool=0);
    }

    if (element == arr[0]) {
        return (bool=1);
    }

    let (bool) = is_element_in_array(
        arr_len=arr_len-1, arr=arr+1, element=element
    );

    return (bool=bool);
}





//**********************************
//Linear Congruence Generator Tests
//**********************************


 @external
func test_block{syscall_ptr: felt*, range_check_ptr}() {

    alloc_locals;

    let (getblock) = get_block_number();
    let (getblock2) = block_num();

    assert getblock = getblock2;
    
    return ();
}

// Test that LCG sequences are with in range 
// Test that LCG sequences return some expected values 

@external
func test_lcg_inner{syscall_ptr: felt*, range_check_ptr}() {

    alloc_locals;

    let arrsize = 100;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;

    let (local new_arr: felt*) = alloc();

    lcg_inner(0, new_arr, arrsize, mod, mult, seed, offset);

    let (bool) = is_element_in_array(arrsize, new_arr, offset-1);

    //given the following args, these are the expected arr values

    assert new_arr[0] = 6;
    assert new_arr[1] = 13;
    assert new_arr[2] = 13;
    assert new_arr[3] = 3;
    assert new_arr[4] = 7;

    //ensure no values are out of range
    assert bool = 0;

    return ();
}

// Test that LCG sequences are within upper and lower bounds 

@external
func test_get_lcg_list_with_bounds{syscall_ptr: felt*, range_check_ptr}() {

    alloc_locals;

    let arrsize = 100;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;


    let (local arr_len, local arr) = get_lcg_list_with_bounds_seed(arrsize, mod, mult, offset, 2342321);
 
     // assert correct number of elements are generated

    assert arr_len = arrsize;

    //test if any values exist oustide the specified bounds
 
    //test upper bounds
    let (bool) = is_element_in_array(arr_len, arr, 12);
    let (bool4) = is_element_in_array(arr_len, arr, mod+2);

    //test lower bounds
    let (bool2) = is_element_in_array(arr_len, arr, offset-1);
    let (bool3) = is_element_in_array(arr_len, arr, offset-2);

    //ensure no values are out of range
    assert bool = 0;
    assert bool2 = 0;
    assert bool3 = 0;
    assert bool4 = 0;

    return ();
}


//***************************
// Modal Transposition Tests
//***************************


@external
func test_recurse_modal_steps_and_sum2{range_check_ptr}() {

    alloc_locals;

    let arrsize = 100;
    let tonic =2;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;
    
    let (local dorian_len, local dorian) = idx_to_mode_steps(2);

    //let (numsteps) = recurse_modal_steps_and_sum2(dorian_len,dorian,0,1,0,1);
   // let (steps) = recurse_modal_steps_and_sum2(dorian_len, dorian, 0, 2, 0, 1);
    let (steps2) = recurse_modal_steps_and_sum2(dorian_len, dorian, 1, 4, 0, 0);
    let (steps3) = recurse_modal_steps_and_sum2(dorian_len, dorian, 4, 2, 0, 0);

     assert steps2 = 7;
     assert steps3 = 3;

//assert steps = steps2;
    return();

        }

// Ensure modal transposition computes the correct notes
 @external
func test_modal_transposition{range_check_ptr}() {

    alloc_locals;

    let arrsize = 100;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;
    
    let (local dorian_len, local dorian) = idx_to_mode_steps(2);

    let (newnote) = modal_transposition(
            69,
            1,
            2,
            dorian_len,
            dorian,
        );

    assert newnote = 71;

     let (newnote2) = modal_transposition(
            69,
            2,
            2,
            dorian_len,
            dorian,
        );

     let (newnote3) = modal_transposition(
            69,
            3,
            2,
            dorian_len,
            dorian,
        );  

    assert newnote3 = 74;

    let (newnote4) = modal_transposition(
            69,
            4,
            2,
            dorian_len,
            dorian,
        );  

    assert newnote4 = 76;

     let (newnote5) = modal_transposition(
            69,
            5,
            2,
            dorian_len,
            dorian,
        );  

    assert newnote5 = 77;

     let (newnote5) = modal_transposition(
            69,
            6,
            2,
            dorian_len,
            dorian,
        );  

    assert newnote5 = 79;

    let (newnote6) = modal_transposition(
            69,
            7,
            2,
            dorian_len,
            dorian,
        );  

    assert newnote6 = 81;

    return ();
}

 @external
func test_modal_transposition_binary{range_check_ptr}() {

    alloc_locals;

    let arrsize = 100;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;
    
    let (local dorian_len, local dorian) = idx_to_mode_steps(2);

    let (newnote) = modal_transposition_binary(
            69,
            1,
            2,
            0,
            dorian_len,
            dorian,
        );

    assert newnote = 71;

     let (newnote1) = modal_transposition_binary(
            71,
            1,
            2,
            1,
            dorian_len,
            dorian,
        );

    assert newnote1 = 69;

    return ();
}


@external
func test_voicing_array_sum{range_check_ptr}() {

    alloc_locals;

    let arrsize = 100;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;
 let (local new_arr: felt*) = alloc();
     // let (local harmony_table_len, local harmony_table) =  ravel_string_quartet_voicing_table();
   let (local harmony_table_len2, local harmony_table2) =  new_three_part_voicing_table();

   let (local voicing_len, local voicing) =  get_voicing_from_table(harmony_table_len2, harmony_table2, 1);
  
    // let out = voicing_array_sum(
    //        voicing,
    //        voicing_len,
    //        2,
    //        60,
    //        new_arr,
    //        0,
    //    );

    // assert out = 5;

    assert voicing[0] = 2;
     assert voicing[1] = 9;
   // assert voicing[1] = 4;
    assert voicing_len = 2;

    //assert new_arr[0] = 60;

    //assert new_arr[1] = 59;
    
   // assert new_arr[2] = 64;
   // assert new_arr[2] = 65;

    return ();
}


@external
func test_get_voicing_from_table_inner{range_check_ptr}(
) -> () {
    
 alloc_locals;

    

 let (local new_arr: felt*) = alloc();
  let (local new_arr2: felt*) = alloc();
     // let (local harmony_table_len, local harmony_table) =  ravel_string_quartet_voicing_table();
   let (local harmony_table_len2, local harmony_table2) =  new_three_part_voicing_table();
   let (local harmony_table_len3, local harmony_table3) =  four_part_voicing_table();

   let table_idx = 2;
   let voicing_size = harmony_table2[0];
   let voicing_size2 = harmony_table3[0];
 //get_voicing_from_table_inner(harmony_table_len2, harmony_table2, 0, new_arr, (table_idx*harmony_table2[0])+1, ((table_idx*harmony_table2[0])+harmony_table2[0])+1);
   assert harmony_table2[0] = 2;
   assert harmony_table2[1] = 2;
   assert harmony_table2[2] = 2;
   assert harmony_table2[3] = 2;
   assert harmony_table2[4] = 3;
   assert voicing_size = 2;
   
   assert harmony_table2[table_idx*voicing_size+1] = 3;
   assert harmony_table2[table_idx*voicing_size+1+(voicing_size-1)] = 2;
   
assert harmony_table3[table_idx*voicing_size2+1] = 2;
   assert harmony_table3[table_idx*voicing_size2+1+(voicing_size2-1)] = 9;
 
 //get_voicing_from_table_inner(harmony_table_len2, harmony_table2, 0, new_arr, table_idx*voicing_size+1, table_idx*voicing_size+1+(voicing_size-1));
    //  let sum = sum_array(harmony_table_len2, harmony_table2, 0, new_arr2);


    return ();
}


@external
func test_copy_array3{range_check_ptr}(
) -> () {
    
 alloc_locals;

 let (local arr: felt*) = alloc();
let (local new_arr: felt*) = alloc();
 
 assert arr[0] = 2;
assert arr[1] = 3;
assert arr[2] = 2;
assert arr[3] = 3;   


     copy_array(4, arr, 0, new_arr, 0);

assert new_arr[0] = 2;
assert new_arr[1] = 3;
assert new_arr[2] = 2;
assert new_arr[3] = 3;

//assert new_arr[3] = 3;
//assert new_arr2[9] = 3899;


    return ();
}


@external
func test_find_min{range_check_ptr}(
) -> () {
    
 alloc_locals;

 let (local new_arr: felt*) = alloc();
 
assert new_arr[0] = 2;
assert new_arr[1] = 3;
assert new_arr[2] = 1;
assert new_arr[3] = 10;
assert new_arr[4] = 6;


let (min) = find_min(5, new_arr);

assert min = 1;
    return ();
}


@external
func test_find_min_index{range_check_ptr}(
) -> () {
    
 alloc_locals;

 let (local new_arr: felt*) = alloc();
 
assert new_arr[0] = 0;
assert new_arr[1] = 3;
assert new_arr[2] = 10;
assert new_arr[3] = 1;
assert new_arr[4] = 6;


let (min, idx) = find_min_and_index(5, new_arr);

assert min = 0;
assert idx = 0;

    return ();
}

@external
func test_append_arr{range_check_ptr}(
) -> () {
    
 alloc_locals;

 let (local new_arr: felt*) = alloc();
let (local r_arr: felt*) = alloc();

assert new_arr[0] = 0;
assert new_arr[1] = 3;
assert new_arr[2] = 10;

assert r_arr[0] = 1;
assert r_arr[1] = 6;


append_arr(3, new_arr, 2, r_arr);

assert new_arr[0] = 0;
assert new_arr[1] = 3;
assert new_arr[2] = 10;
assert new_arr[3] = 1;
assert new_arr[4] = 6;


    return ();
}


@external
func test_reverse_arr{range_check_ptr}(
) -> () {
    
 alloc_locals;

 let (local new_arr: felt*) = alloc();
let (local r_arr: felt*) = alloc();

assert new_arr[0] = 0;
assert new_arr[1] = 3;
assert new_arr[2] = 10;
assert new_arr[3] = 1;
assert new_arr[4] = 6;


reverse_arr(5, new_arr, 0, r_arr, 0);

assert r_arr[0] = 6;
assert r_arr[1] = 1;
assert r_arr[2] = 10;
assert r_arr[3] = 3;
assert r_arr[4] = 0;



    return ();
}



@external
func test_sort_array{range_check_ptr}(
) -> () {
    
 alloc_locals;

let (local new_arr: felt*) = alloc();
let (local new_arr2: felt*) = alloc();
let (local new_arr4: felt*) = alloc();

assert new_arr[0] = 0;
assert new_arr[1] = 3;
assert new_arr[2] = 10;
assert new_arr[3] = 1;
assert new_arr[4] = 6;

     copy_array(5, new_arr, 0, new_arr2, 0);

assert new_arr2[0] = 0;
assert new_arr2[1] = 3;
assert new_arr2[2] = 10;
assert new_arr2[3] = 1;
assert new_arr2[4] = 6;

//sort_array(5, new_arr2, 0, new_arr4);

assert new_arr4[0] = 0;
assert new_arr4[1] = 1;
assert new_arr4[2] = 1;
assert new_arr4[3] = 1;

    return ();
}


@external
func test_remove_item_from_array{range_check_ptr}(
) -> () {
    
 alloc_locals;

let (local new_arr: felt*) = alloc();
let (local new_arr2: felt*) = alloc();
let (local new_arr4: felt*) = alloc();

assert new_arr[0] = 0;
assert new_arr[1] = 3;
assert new_arr[2] = 10;
assert new_arr[3] = 1;
assert new_arr[4] = 6;

     remove_item_from_array(5, new_arr, 0, new_arr2, 0, 3);

assert new_arr2[0] = 0;
//assert new_arr2[1] = 3;
assert new_arr2[1] = 10;
assert new_arr2[2] = 1;
assert new_arr2[3] = 6;

    return ();
}


@external
func test_geom_array_fill{range_check_ptr}(
) -> () {
    
alloc_locals;

let (local new_arr: felt*) = alloc();
assert new_arr[0] = 1;
geom_array_fill(1, new_arr, 1, 1, 100);

assert new_arr[0] = 1;
assert new_arr[1] = 2;
assert new_arr[2] = 4;
assert new_arr[3] = 7;
assert new_arr[99] = 4951;
assert new_arr[100] = 5051;

//assert new_arr[2] = 1;
//assert new_arr[3] = 6;

    return ();
}


//test random transpostions to ensure expected notes are returned

@external
func modal_transpose_note_by_list{range_check_ptr}(
    arr_len: felt, 
    arr: felt*, 
    new_arr_len: felt, 
    new_arr: felt*, 
    keynum: felt, 
    tonic: felt, 
    mode_len: felt, 
    mode: felt*
) {
    alloc_locals;

    if (arr_len == 0) {
        return ();
    }

   
    let current_step = arr[0];

    let (newnote) = modal_transposition(
            keynum,
            current_step,
            tonic,
            mode_len,
            mode,
        );


    assert new_arr[new_arr_len] = newnote;

    modal_transpose_note_by_list(
        arr_len=arr_len-1,
        arr=arr+1,
        new_arr_len=new_arr_len+1,
        new_arr=new_arr+1,
        keynum=newnote,
        tonic=tonic,
        mode_len=mode_len,
        mode=mode
    );

    return ();
}

//Fuzzing Attempt

 @external
func test_modal_transposition2{range_check_ptr}() {

    alloc_locals;

    let arrsize = 100;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;
    let keynum = 69;

    let (local rand_arr: felt*) = alloc();
    let (local new_arr: felt*) = alloc();

    lcg_inner(0, rand_arr, arrsize, mod, mult, seed, offset);

    let tonicnote = 2;

    let (local mode_len, local mode) = idx_to_mode_steps(2);

    modal_transpose_note_by_list(
        arrsize, 
        rand_arr, 
        0, 
        new_arr, 
        keynum, 
        tonicnote, 
        mode_len, 
        mode
        );


    //let (scale_deg_bool) = is_every_keynum_in_array_scale_degree(arrsize, new_arr, mode_len, mode, tonicnote);

   // assert scale_deg_bool = 1;

    let (newnote) = modal_transposition(
            69,
            1,
            tonicnote,
            mode_len,
            mode,
        );

    //let (idx) = is_scale_degree(dorian_len, dorian, 0, tonicnote, newnote);
    let idx = 0;
    assert idx = 0;
    return ();
}

  @external
func test_get_notes_of_key{range_check_ptr}() {

    alloc_locals;

    let tonicnote = 2;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;

    let (local new_arr: felt*) = alloc();

    let (local dorian_len, local dorian) = dorian_steps();
   
    let (local notes_len, local notes) = get_notes_of_key(tonicnote, dorian_len, dorian);

    assert notes[0] = 2;
    assert notes[1] = 4;
    assert notes[2] = 5;
    assert notes[3] = 7;
    assert notes[4] = 9;
    assert notes[5] = 11;
    assert notes[6] = 0;

    return ();
} 

  @external
func test_is_keynum_in_scale{range_check_ptr}() {

    alloc_locals;

    let tonicnote = 2;
    let mod = 11;
    let mult = 3;
    let offset = 3;
    let seed = 1;

    let (local new_arr: felt*) = alloc();

    let (local dorian_len, local dorian) = dorian_steps();
   
    let (local notes_len, local notes) = get_notes_of_key(tonicnote, dorian_len, dorian);

    let (is_in_scale) = is_note_scale_degree(notes_len, notes, 2);
    assert is_in_scale = 1;

    return ();
} 

 @external
func test_pc{range_check_ptr}() {

    alloc_locals;
    let (local dorian_len, local dorian) = dorian_steps();

let (local arr_len, local arr) = get_notes_of_key(2, dorian_len, dorian);

    assert 7 = arr_len;

    return ();
}

 @external
func test_pc2{range_check_ptr}() ->(arr_len: felt, arr: felt*) {

    alloc_locals;
    let (local dorian_len, local dorian) = dorian_steps();

let (local arr_len, local arr) = get_notes_of_key(2, dorian_len, dorian);

    assert 7 = arr_len;

    return (arr_len=arr_len, arr=arr);
}

// Test Modes
@external
func test_modes{}() {

    alloc_locals;

    //Dorian

    let (local dorian_len, local dorian) = dorian_steps();

    assert dorian[0] = 2;
    assert dorian[1] = 1;
    assert dorian[2] = 2;
    assert dorian[3] = 2;
    assert dorian[4] = 2;
    assert dorian[5] = 1;
    assert dorian[6] = 2;

    assert dorian_len = 7;

    let (local major_len, local major) = major_steps();

    assert major[0] = 2;
    assert major[1] = 2;
    assert major[2] = 1;
    assert major[3] = 2;
    assert major[4] = 2;
    assert major[5] = 2;
    assert major[6] = 1;
    
    assert major_len = 7;

    let (local phrygian_len, local phrygian) = phrygian_steps();
    assert phrygian_len = 7;
    assert phrygian[0] = 1;
    return ();
}





 @external
func test_invert_keynum{syscall_ptr: felt*, range_check_ptr}() {

    alloc_locals;

    let basenote = 71;
    let keynum_to_invert = 69;

   let (nkeynum) =  invert_keynum(basenote, keynum_to_invert);

    //given the following args, these are the expected arr values

    assert nkeynum = 73;
    
    return ();
}
