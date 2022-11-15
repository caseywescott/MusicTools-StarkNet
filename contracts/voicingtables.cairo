%lang starknet
from starkware.cairo.common.alloc import alloc

//*****************************************************************************************************
// Voicing Tables 
//
// Harmonies can be defined as an array of modal interval steps transposing a base pitch
// 
// To enable Harmonization of N Parts, Voicing Tables are specified as arrays with the following format:
//
// [num_harmonies_per_voice, table1_interval_above_base_note_0, table1_interval_above_base_note_1...]
// For example, a voicing table of a single 1st position triad chord would be: 
// [2, 2, 4] -> ['two part harmony', 'transpose two steps above note', 'transpose 4 steps above' note]
//
//*****************************************************************************************************

@view
func two_part_voicing_table{range_check_ptr}() -> (table_len: felt, table: felt*) {
    alloc_locals;

    let (local table) = alloc();

    // assert first element as the number of harmonies in a voicing above a note
    // Three part including transposed note

    assert [table + 0] = 1;
    // third
    assert [table + 1] = 2;
    // fourth
    assert [table + 2] = 3;
    // fifth
    assert [table + 3] = 4;
    // sixth
    assert [table + 4] = 5;
    // octave
    assert [table + 5] = 7;
    // tenth
    assert [table + 6] = 9;

    return (table_len=7, table=table);
}

@view
func three_part_voicing_table{range_check_ptr}() -> (table_len: felt, table: felt*) {
    alloc_locals;

    let (local table) = alloc();

    // assert first element as the number of harmonies in a voicing above a note
    // Three part including transposed note

    assert [table + 0] = 2;

    // 1st position triad
    assert [table + 1] = 2;
    assert [table + 2] = 4;

    // 2nd position triad
    assert [table + 3] = 2;
    assert [table + 4] = 5;

    // 3rd position triad
    assert [table + 5] = 3;
    assert [table + 6] = 5;

    // 3rd and Octave
    assert [table + 7] = 2;
    assert [table + 8] = 7;

    // 3rd and Tenth
    assert [table + 9] = 2;
    assert [table + 10] = 9;

    return (table_len=11, table=table);
}

@view
func four_part_voicing_table{range_check_ptr}() -> (table_len: felt, table: felt*) {
    alloc_locals;

    let (local table) = alloc();

    // assert first element as the number of harmonies in a voicing above a note
    // Four part including transposed note

    assert [table + 0] = 3;

    assert [table + 1] = 2;
    assert [table + 2] = 4;
    assert [table + 3] = 7;

    assert [table + 4] = 2;
    assert [table + 5] = 5;
    assert [table + 6] = 7;

    assert [table + 7] = 2;
    assert [table + 8] = 4;
    assert [table + 9] = 9;

    assert [table + 10] = 2;
    assert [table + 11] = 5;
    assert [table + 12] = 9;

    assert [table + 13] = 2;
    assert [table + 14] = 9;
    assert [table + 15] = 11;

    assert [table + 16] = 2;
    assert [table + 17] = 7;
    assert [table + 18] = 9;

    assert [table + 19] = 3;
    assert [table + 20] = 5;
    assert [table + 21] = 7;

    assert [table + 22] = 3;
    assert [table + 23] = 5;
    assert [table + 24] = 9;

    assert [table + 25] = 4;
    assert [table + 26] = 9;
    assert [table + 27] = 11;

    assert [table + 28] = 4;
    assert [table + 29] = 9;
    assert [table + 30] = 13;

    assert [table + 31] = 5;
    assert [table + 32] = 7;
    assert [table + 33] = 9;

    assert [table + 34] = 5;
    assert [table + 35] = 7;
    assert [table + 36] = 11;

    assert [table + 37] = 5;
    assert [table + 38] = 9;
    assert [table + 39] = 11;

    assert [table + 40] = 5;
    assert [table + 41] = 9;
    assert [table + 42] = 7;

    assert [table + 43] = 5;
    assert [table + 44] = 10;
    assert [table + 45] = 12;

    assert [table + 46] = 7;
    assert [table + 47] = 9;
    assert [table + 48] = 11;

    return (table_len=49, table=table);
}


// Voicing Table derived from Ravel String Quartet: https://www.youtube.com/watch?v=ieRQyyPowH0&t=3s

@view
func ravel_string_quartet_voicing_table{range_check_ptr}() -> (table_len: felt, table: felt*) {
    alloc_locals;

    let (local table) = alloc();

    // assert first element as the number of harmonies in a voicing above a note
    // Four part including transposed note

    assert [table + 0] = 3;

    assert [table + 1] = 2;
    assert [table + 2] = 4;
    assert [table + 3] = 9;

    assert [table + 4] = 2;
    assert [table + 5] = 5;
    assert [table + 6] = 11;

    assert [table + 7] = 2;
    assert [table + 8] = 8;
    assert [table + 9] = 11;

    assert [table + 10] = 3;
    assert [table + 11] = 5;
    assert [table + 12] = 8;

    assert [table + 13] = 3;
    assert [table + 14] = 5;
    assert [table + 15] = 9;

    assert [table + 16] = 3;
    assert [table + 17] = 6;
    assert [table + 18] = 12;

    assert [table + 19] = 3;
    assert [table + 20] = 8;
    assert [table + 21] = 12;

    assert [table + 22] = 3;
    assert [table + 23] = 9;
    assert [table + 24] = 12;

    assert [table + 25] = 3;
    assert [table + 26] = 9;
    assert [table + 27] = 13;

    assert [table + 28] = 3;
    assert [table + 29] = 9;
    assert [table + 30] = 14;

    assert [table + 31] = 4;
    assert [table + 32] = 6;
    assert [table + 33] = 9;

    assert [table + 34] = 4;
    assert [table + 35] = 8;
    assert [table + 36] = 13;

    assert [table + 37] = 4;
    assert [table + 38] = 9;
    assert [table + 39] = 13;

    assert [table + 40] = 5;
    assert [table + 41] = 9;
    assert [table + 42] = 13;

    assert [table + 43] = 5;
    assert [table + 44] = 11;
    assert [table + 45] = 14;

    assert [table + 46] = 6;
    assert [table + 47] = 8;
    assert [table + 48] = 11;

    assert [table + 49] = 6;
    assert [table + 50] = 8;
    assert [table + 51] = 14;

    assert [table + 52] = 6;
    assert [table + 53] = 10;
    assert [table + 54] = 15;

    assert [table + 55] = 6;
    assert [table + 56] = 11;
    assert [table + 57] = 15;

    assert [table + 58] = 6;
    assert [table + 59] = 12;
    assert [table + 60] = 15;

    assert [table + 61] = 7;
    assert [table + 62] = 9;
    assert [table + 63] = 12;

    assert [table + 64] = 7;
    assert [table + 65] = 12;
    assert [table + 66] = 16;

    return (table_len=67, table=table);
}


//***********************************************************************
// Indexed map to Voicing Tables
// Helpful for modulating harmonies and interacting with client dropdown
//***********************************************************************

@view
func idx_to_voicing_tables{range_check_ptr}(modeidx: felt) -> (mode_len: felt, mode: felt*) {
    alloc_locals;

    if (modeidx == 0) {
        let (local mode_len1, local mode1) = two_part_voicing_table();
        return (mode_len1, mode1);
    }
    if (modeidx == 1) {
        let (local mode_len1, local mode1) = three_part_voicing_table();
        return (mode_len1, mode1);
    } else {
        let (local mode_len1, local mode1) = four_part_voicing_table();
        return (mode_len1, mode1);
    }
}

@view
func get_voicing_from_table_inner{range_check_ptr}(
    arr_len: felt, arr: felt*, new_arr_len: felt, new_arr: felt*, startidx: felt, endidx
) -> (new_arr_len: felt, new_arr: felt*) {
    
    alloc_locals;

    if (startidx == 4) {

        return (new_arr_len=new_arr_len, new_arr=new_arr);
    }


    assert new_arr[new_arr_len] = arr[startidx];

    get_voicing_from_table_inner(
        arr_len=arr_len, 
        arr=arr, 
        new_arr_len=new_arr_len+1, 
        new_arr=new_arr+1, 
        startidx=startidx+1,endidx=endidx
    );

        return (new_arr_len=new_arr_len, new_arr=new_arr);
}


// to:do putting a mod on the table_idx to prevent out of range errors

@view
func get_voicing_from_table{range_check_ptr}(
    voicing_arr_len: felt, voicing_arr: felt*, table_idx: felt,
) -> (table_len: felt, table: felt*) {
    
    alloc_locals;

    let (local table) = alloc();
   let voicing_size = voicing_arr[0];
 get_voicing_from_table_inner(voicing_arr_len, voicing_arr, 0, table, table_idx*voicing_size+1, table_idx*voicing_size+voicing_size+1+(voicing_size-1));
    return (voicing_arr[0], table);
}

func voicing_array_sum(arr: felt*, size: felt, idx: felt, keynum: felt, new_arr: felt*, new_arr_size: felt) -> felt {
    if (idx == 0) {
        return 0;
    }

    // size is not zero.
    let sum_of_rest = voicing_array_sum(arr=arr + 1, size=size - 1, idx=idx-1, keynum=keynum, new_arr=new_arr+1, new_arr_size=new_arr_size+1);
    assert new_arr[new_arr_size] = sum_of_rest + keynum;
    return arr[0] + sum_of_rest;
}

