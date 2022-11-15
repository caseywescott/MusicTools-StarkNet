%lang starknet

from starkware.starknet.common.syscalls import get_block_number
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_nn, is_le, is_not_zero
from starkware.cairo.common.math import unsigned_div_rem, assert_nn

from contracts.LinearCongruentialGenerator import (block_num, lcg_inner, get_lcg_list_with_offset, get_lcg_list_with_bounds, get_lcg_list_with_bounds_seed)
from contracts.structs import (PitchClass, PitchInterval, CounterPointMetrics, MelodicMetrics, HarmonizerInputArgs)
from contracts.modes import (major_steps, minor_steps, lydian_steps, mixolydian_steps, dorian_steps, phrygian_steps, locrian_steps, aeolian_steps, harmonicminor_steps, 
naturalminor_steps, chromatic_steps, pentatonic_steps, idx_to_mode_steps)
from contracts.consts import (OCTAVEBASE)
from contracts.voicingtables import (idx_to_voicing_tables, two_part_voicing_table, three_part_voicing_table, four_part_voicing_table, ravel_string_quartet_voicing_table, 
get_voicing_from_table_inner, get_voicing_from_table, voicing_array_sum)
from contracts.sequencablecollections import (geom_array_fill, array_fill, geom_array_diff_fill, copy_array, append_arr, reverse_arr)
from contracts.pitchclass import (pc_to_keynum, diff_between_pc, mode_notes_above_note_base, get_notes_of_key, keynum_to_scale_degree, get_scale_degree, is_note_scale_degree, is_keynum_scale_degree, 
is_every_keynum_in_array_scale_degree, recurse_modal_steps_and_sum2, recurse_modal_steps_and_sum, modal_transposition_inner, modal_transposition, 
recurse_modal_steps_and_sum_descend, modal_transposition_descend_inner, modal_transposition_descend, modal_transposition_binary, invert_keynum)


@view
func realms_disklavier{range_check_ptr}(drawer_data: HarmonizerInputArgs
) -> (out_data_len: felt, out_data: felt*) {
    alloc_locals;

     let num_divs = 1;
 

    let (local out_data: felt*) = alloc();
    let (local out_data2: felt*) = alloc();
    let (local out_data3: felt*) = alloc();
    let (local out_data4: felt*) = alloc();

    let (local out_data5: felt*) = alloc();

    let (local new_arr: felt*) = alloc();
        let (local rand2_arr: felt*) = alloc();

    let (local voice2_arr: felt*) = alloc();

    let (local diff_arr: felt*) = alloc();
    let (local diff2_arr: felt*) = alloc();
    let (local diff3_arr: felt*) = alloc();
    let (local rev_arr: felt*) = alloc();

    let (local mode_steps_len, local mode_steps) = idx_to_mode_steps(drawer_data.pitchcollection_idx);

    let num_input_notes = 50;
    let tonic = drawer_data.tonic_idx;

    let arrsize = 300;
    let mod = 5;
    let mult = 2;
    let offset = 1;
    let seed = 1;

    let keynum = 69;

    let keynum2 = 69;

    let keynum3 = 69;

    let (local randarr_len, local randarr) = get_lcg_list_with_bounds_seed(arrsize, mod, mult, offset, 2342321+drawer_data.spread_val);


geom_array_diff_fill(0, new_arr, 0, diff_arr, 1, 1, 50);
geom_array_diff_fill(0, rand2_arr, 0, diff2_arr, 3, 1, 50);

reverse_arr(50, new_arr, 0, rev_arr, 0);

make_notes_inner(50, new_arr, 50, diff_arr, 0, mode_steps_len, mode_steps, randarr_len, randarr, keynum, 20, tonic, 0, out_data);

make_notes_inner(50, new_arr, 50, diff_arr, 0, mode_steps_len, mode_steps, randarr_len, randarr, keynum2, 30, tonic, 0, out_data2);

make_notes_inner(50, new_arr, 50, diff_arr, 0, mode_steps_len, mode_steps, randarr_len, randarr, keynum3, 50, tonic, 0, out_data3);

make_notes_inner3(50, new_arr, 23040, 50, diff_arr, 0, mode_steps_len, mode_steps, randarr_len, randarr, keynum3, 40, tonic, 0, out_data4);

make_notes_inner3(50, new_arr, 23040+11520, 50, diff_arr, 0, mode_steps_len, mode_steps, randarr_len, randarr, keynum3-12, 10, tonic, 0, out_data5);


//make_notes_inner2(50, new_arr, 5000, 50, diff_arr, 0, mode_steps_len, mode_steps, randarr_len, randarr, keynum-36, 20, tonic, 0, out_data4);


let (local chords_len, local chords) = make_chords(tonic, drawer_data.pitchcollection_idx, drawer_data);

append_arr(50*4, out_data, chords_len, chords);
append_arr(chords_len+(50*4), out_data, (50*4), out_data2);

append_arr(chords_len+(50*4)+(50*4), out_data, (50*4), out_data3);
append_arr(chords_len+(50*4)+(50*4)+(50*4), out_data, (50*4), out_data4);
append_arr(chords_len+(50*4)+(50*4)+(50*4)+(50*4), out_data, (50*4), out_data4);

//append_arr(chords_len+(50*4)+(50*4)+(50*4), out_data, (50*4), out_data4);


//append_arr(50*4, out_data, chords_len, chords, 0);
//append_arr((50*4)+chords_len, out_data, 50*4, out_data2, 0);

   // return (out_data_len=(50*4)+chords_len+(50*4), out_data=out_data);
     return (out_data_len=chords_len+(50*4)+(50*4)+(50*4)+(50*4)+(50*4), out_data=out_data);

}


@view
func make_chords{range_check_ptr}(tonic: felt, modeidx: felt, drawer_data: HarmonizerInputArgs
) -> (out_data_len: felt, out_data: felt*) {
    alloc_locals;

    let (local out_data: felt*) = alloc();
    let (local new_arr: felt*) = alloc();
    let (local diff_arr: felt*) = alloc();

    let (local mode_steps_len, local mode_steps) = idx_to_mode_steps(drawer_data.pitchcollection_idx);

    let num_input_notes = 50;

    let arrsize = 50;
    let mod = 5;
    let mult = 2;
    let offset = 1;
    let seed = 1;

    let keynum = 36;

    let (local randarr_len, local randarr) = get_lcg_list_with_bounds_seed(arrsize, mod, mult, offset, 342321+drawer_data.harmonies_val);


//assert new_arr[0] = 1;
//assert diff_arr[0] = 1;

geom_array_diff_fill(0, new_arr, 0, diff_arr, 1, 1, 50);

make_chord_notes_inner(50, new_arr, 0, 0, mode_steps_len, mode_steps, randarr_len, randarr, keynum, tonic, 0, out_data);



    return (out_data_len=50*8, out_data=out_data);
}

   
   


@view
func make_chord_notes_inner{range_check_ptr}(
    tick_arr_len: felt, tick_arr: felt*, tick_val: felt, idx: felt, mode_steps_len: felt, mode_steps: felt*, randarr_len: felt, randarr: felt*, prevnote: felt, tonic: felt, out_data_len: felt, out_data: felt*
) -> () {
    alloc_locals;

    if (idx == tick_arr_len) {
        return ();
    }
    let inc_add =8;
    let (_, local direction) = unsigned_div_rem(randarr[idx], 2);

   // let tonic = 2; //D
    let scale_step = randarr[idx];
    let (newkeynum) = modal_transposition_binary(prevnote, scale_step, tonic, direction, mode_steps_len, mode_steps);

    let (newkeynum2) = modal_transposition_binary(newkeynum, 4, tonic, direction, mode_steps_len, mode_steps);

    let tickinc = 960; //length of bar

    assert out_data[out_data_len + 0] = tickinc;  // duration
    assert out_data[out_data_len + 1] = newkeynum;  // new note
    assert out_data[out_data_len + 2] = tick_val;  // tick
    assert out_data[out_data_len + 3] = 40+(randarr[idx]*5);  // velocity

    assert out_data[out_data_len + 4] = tickinc;  // duration
    assert out_data[out_data_len + 5] = newkeynum2;  // new note
    assert out_data[out_data_len + 6] = tick_val;  // tick
    assert out_data[out_data_len + 7] = 40+(randarr[idx]*5);  // velocity

    make_chord_notes_inner(
    tick_arr_len=tick_arr_len,
        tick_arr=tick_arr,
        tick_val=tick_val+tickinc,
        idx=idx+1,
        mode_steps_len=mode_steps_len,
        mode_steps=mode_steps,
        randarr_len=randarr_len,
        randarr=randarr,
        prevnote=newkeynum,
        tonic=tonic,
        out_data_len=out_data_len + inc_add,
        out_data=out_data
    );

    return ();
}




@view
func make_notes_inner{range_check_ptr}(
    tick_arr_len: felt, tick_arr: felt*, dur_arr_len: felt, dur_arr: felt*, idx: felt, mode_steps_len: felt, mode_steps: felt*, randarr_len: felt, randarr: felt*, prevnote: felt, scalar: felt, tonic: felt, out_data_len: felt, out_data: felt*
) -> () {
    alloc_locals;

    if (idx == tick_arr_len) {
        return ();
    }
    let inc_add =4;
    let (_, local direction) = unsigned_div_rem(randarr[idx], 2);

  


    //let tonic = 2; //D
    let scale_step = randarr[idx];
    let (newkeynum) = modal_transposition_binary(prevnote, scale_step, tonic, direction, mode_steps_len, mode_steps);

    //make higher notes louder
    let (q, local m) = unsigned_div_rem(newkeynum, 6);

    //limit key range
    local direction = is_le(72, newkeynum);

    assert out_data[out_data_len + 0] = dur_arr[idx]*scalar;  // duration
    assert out_data[out_data_len + 1] = newkeynum-(24*direction) ;  // new note
    assert out_data[out_data_len + 2] = tick_arr[idx]*scalar;  // tick
    assert out_data[out_data_len + 3] = 40+(randarr[idx]*8)+(q*2);  // velocity

    make_notes_inner(
        tick_arr_len=tick_arr_len,
        tick_arr=tick_arr,
        dur_arr_len=dur_arr_len,
        dur_arr=dur_arr,
        idx=idx+1,
        mode_steps_len=mode_steps_len,
        mode_steps=mode_steps,
        randarr_len=randarr_len,
        randarr=randarr,
        prevnote=newkeynum,
        scalar=scalar,
        tonic=tonic,
        out_data_len=out_data_len + inc_add,
        out_data=out_data
    );

    return ();
}

@view
func make_notes_inner2{range_check_ptr}(
    tick_arr_len: felt, tick_arr: felt*, tickval: felt, dur_arr_len: felt, dur_arr: felt*, idx: felt, mode_steps_len: felt, mode_steps: felt*, randarr_len: felt, randarr: felt*, prevnote: felt, scalar: felt, tonic: felt, out_data_len: felt, out_data: felt*
) -> () {
    alloc_locals;

    if (idx == tick_arr_len) {
        return ();
    }
    let inc_add =4;
    let (_, local direction) = unsigned_div_rem(randarr[idx], 2);

  
    let tickinc = 160; //length of bar


    //let tonic = 2; //D
    let scale_step = randarr[idx];
    let (newkeynum) = modal_transposition_binary(prevnote, scale_step, tonic, direction, mode_steps_len, mode_steps);

    //make higher notes louder
    let (q, local m) = unsigned_div_rem(newkeynum, 6);

    //limit key range
    local direction = is_le(72, newkeynum);

    assert out_data[out_data_len + 0] = tickinc;  // duration
    assert out_data[out_data_len + 1] = newkeynum-(24*direction) ;  // new note
    assert out_data[out_data_len + 2] = tickval;  // tick
    assert out_data[out_data_len + 3] = 40+(randarr[idx]*8)+(q*2);  // velocity

    make_notes_inner2(
        tick_arr_len=tick_arr_len,
        tick_arr=tick_arr,
        tickval=tickval+tickinc,
        dur_arr_len=dur_arr_len,
        dur_arr=dur_arr,
        idx=idx+1,
        mode_steps_len=mode_steps_len,
        mode_steps=mode_steps,
        randarr_len=randarr_len,
        randarr=randarr,
        prevnote=newkeynum,
        scalar=scalar,
        tonic=tonic,
        out_data_len=out_data_len + inc_add,
        out_data=out_data
    );

    return ();
}

@view
func make_notes_inner3{range_check_ptr}(
    tick_arr_len: felt, tick_arr: felt*, tick_offset: felt, dur_arr_len: felt, dur_arr: felt*, idx: felt, mode_steps_len: felt, mode_steps: felt*, randarr_len: felt, randarr: felt*, prevnote: felt, scalar: felt, tonic: felt, out_data_len: felt, out_data: felt*
) -> () {
    alloc_locals;

    if (idx == tick_arr_len) {
        return ();
    }
    let inc_add =4;
    let (_, local direction) = unsigned_div_rem(randarr[idx], 2);

  


    //let tonic = 2; //D
    let scale_step = randarr[idx];
    let (newkeynum) = modal_transposition_binary(prevnote, scale_step, tonic, direction, mode_steps_len, mode_steps);

    //make higher notes louder
    let (q, local m) = unsigned_div_rem(newkeynum, 6);

    //limit key range
    local direction = is_le(72, newkeynum);

    assert out_data[out_data_len + 0] = dur_arr[idx]*scalar;  // duration
    assert out_data[out_data_len + 1] = newkeynum-(24*direction) ;  // new note
    assert out_data[out_data_len + 2] = tick_offset+tick_arr[idx]*scalar;  // tick
    assert out_data[out_data_len + 3] = 40+(randarr[idx]*8)+(q*2);  // velocity

    make_notes_inner3(
        tick_arr_len=tick_arr_len,
        tick_arr=tick_arr,
        tick_offset=tick_offset,
        dur_arr_len=dur_arr_len,
        dur_arr=dur_arr,
        idx=idx+1,
        mode_steps_len=mode_steps_len,
        mode_steps=mode_steps,
        randarr_len=randarr_len,
        randarr=randarr,
        prevnote=newkeynum,
        scalar=scalar,
        tonic=tonic,
        out_data_len=out_data_len + inc_add,
        out_data=out_data
    );

    return ();
}

