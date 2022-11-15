%lang starknet
//%builtins pedersen range_check

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

from contracts.utils import (abs_diff, find_min, find_min_and_index)
from realms_disklavier import  (realms_disklavier)

//*******************************************************************************************************
//  MUSIC UTILS & Auto-Harmonization Functions
//
//  The defined functions below can be used for generative music algorithms.
//  Using these operations as building blocks, music of arbitrary criteria can be generated.
//
//  As an example, the auto-harmonization function 'Harmonizer' in koji.cairo takes in notes/melodies
//  and generates notes to be played simultaneously whilst sounding harmonious. 
//
//  'Harmonizer' generates different harmonic solutions every block by way of a 
//  linear congruence formula varying note transpositions via Voicing Tables of Modal Intervals.
//********************************************************************************************************

// Harmonize notes for each interval in a Voicing Table

@view
func harmonization_by_voicing_table_inner{range_check_ptr}(
    arr_len: felt,
    arr: felt*,
    new_arr_len: felt,
    new_arr: felt*,
    arr_idx: felt,
    inc: felt,
    randarr_len: felt,
    randarr: felt*,
    randinc: felt,
    mode1_len: felt,
    mode1: felt*,
    harmony_table_len: felt,
    harmony_table: felt*,
    drawer_data: HarmonizerInputArgs,
) -> () {
    alloc_locals;

    if (arr_idx == arr_len - 6) {
        return ();
    }

    let (_, local randx) = unsigned_div_rem(randinc, randarr_len);

    let current_val = arr[arr_idx];

    let rand_i = randarr[randx];

    // operate on note data by block of four elements
    let numharms = harmony_table[0];

    let (local outarr_len, local outarr) = note_generator(
        arr_len,
        arr,
        new_arr_len,
        new_arr,
        arr_idx,
        mode1_len,
        mode1,
        harmony_table_len,
        harmony_table,
        randarr_len,
        randarr,
        randinc,
        drawer_data,
        numharms,
    );

    harmonization_by_voicing_table_inner(
        arr_len=arr_len,
        arr=arr,
        new_arr_len=outarr_len,
        new_arr=outarr,
        arr_idx=arr_idx + 4,
        inc=inc + 1,
        randarr_len=randarr_len,
        randarr=randarr,
        randinc=randinc + 1,
        mode1_len=mode1_len,
        mode1=mode1,
        harmony_table_len=harmony_table_len,
        harmony_table=harmony_table,
        drawer_data=drawer_data,
    );
    return ();
}

// Harmonize notes based on given Voicing Table

@view
func harmonization_by_voicing_table{syscall_ptr: felt*, range_check_ptr}(
    site_data_len: felt, site_data: felt*, drawer_data: HarmonizerInputArgs
) -> (outdata_len: felt, outdata: felt*) {
    alloc_locals;

    let (local new_arr: felt*) = alloc();

    //let (local harmony_table_len, local harmony_table) = three_part_voicing_table();
    let (local harmony_table_len, local harmony_table) =  ravel_string_quartet_voicing_table();
    let (local mode_steps_len, local mode_steps) = idx_to_mode_steps(
        drawer_data.pitchcollection_idx
    );
    let (local num_input_notes, _) = unsigned_div_rem(drawer_data.last_note_data_idx, 4);

    // Scale Spread values to map to size harmony_table_len or humber of voicings in table
    let (local num_voicings_in_table, _) = unsigned_div_rem(
        harmony_table_len - 1, harmony_table[0]
    );

    let numharms = harmony_table[0];

    let (local randarr_len, local randarr) = get_lcg_list_with_bounds(
        num_input_notes, num_voicings_in_table, 2, 0
    );

    harmonization_by_voicing_table_inner(
        site_data_len,
        site_data,
        0,
        new_arr,
        1,
        0,
        randarr_len,
        randarr,
        0,
        mode_steps_len,
        mode_steps,
        harmony_table_len,
        harmony_table,
        drawer_data,
    );

    return (
        outdata_len=drawer_data.last_note_data_idx * numharms * drawer_data.num_divisions,
        outdata=new_arr,
    );
}

@view
func harmonization_by_voicing_table2{syscall_ptr: felt*, range_check_ptr}(
    site_data_len: felt, site_data: felt*, drawer_data: HarmonizerInputArgs, 
    harmony_table_len: felt, harmony_table: felt*
) -> (outdata_len: felt, outdata: felt*) {
    alloc_locals;

    let (local new_arr: felt*) = alloc();

    //let (local harmony_table_len, local harmony_table) = three_part_voicing_table();
   // let (local harmony_table_len, local harmony_table) =  ravel_string_quartet_voicing_table();
    let (local mode_steps_len, local mode_steps) = idx_to_mode_steps(
        drawer_data.pitchcollection_idx
    );
    let (local num_input_notes, _) = unsigned_div_rem(drawer_data.last_note_data_idx, 4);

    // Scale Spread values to map to size harmony_table_len or humber of voicings in table
    let (local num_voicings_in_table, _) = unsigned_div_rem(
        harmony_table_len - 1, harmony_table[0]
    );

    let numharms = harmony_table[0];

    let (local randarr_len, local randarr) = get_lcg_list_with_bounds(
        num_input_notes, num_voicings_in_table, 2, 0
    );

    harmonization_by_voicing_table_inner(
        site_data_len,
        site_data,
        0,
        new_arr,
        1,
        0,
        randarr_len,
        randarr,
        0,
        mode_steps_len,
        mode_steps,
        harmony_table_len,
        harmony_table,
        drawer_data,
    );

    return (
        outdata_len=drawer_data.last_note_data_idx * numharms * drawer_data.num_divisions,
        outdata=new_arr,
    );
}


//IN PROGRESS Harmonizer with metrics                

@view
func harmonization_by_voicing_table_with_metrics{syscall_ptr: felt*, range_check_ptr}(
    site_data_len: felt, site_data: felt*, drawer_data: HarmonizerInputArgs, cpt_metrics: CounterPointMetrics
) -> (outdata_len: felt, outdata: felt*) {
    alloc_locals;

    let (local new_arr: felt*) = alloc();

    //let (local harmony_table_len, local harmony_table) = three_part_voicing_table();
    let (local harmony_table_len, local harmony_table) =  ravel_string_quartet_voicing_table();
    let (local mode_steps_len, local mode_steps) = idx_to_mode_steps(
        drawer_data.pitchcollection_idx
    );
    let (local num_input_notes, _) = unsigned_div_rem(drawer_data.last_note_data_idx, 4);

    // Scale Spread values to map to size harmony_table_len or humber of voicings in table
    let (local num_voicings_in_table, _) = unsigned_div_rem(
        harmony_table_len - 1, harmony_table[0]
    );

    let numharms = harmony_table[0];

    let (local randarr_len, local randarr) = get_lcg_list_with_bounds(
        num_input_notes, num_voicings_in_table, 2, 0
    );

    harmonization_by_voicing_table_inner(
        site_data_len,
        site_data,
        0,
        new_arr,
        1,
        0,
        randarr_len,
        randarr,
        0,
        mode_steps_len,
        mode_steps,
        harmony_table_len,
        harmony_table,
        drawer_data,
    );

    return (
        outdata_len=drawer_data.last_note_data_idx * numharms * drawer_data.num_divisions,
        outdata=new_arr,
    );
}


//***************************
// Note Generation Functions
//***************************

// Notes consist of the following data: Duration, KeyNum, Tick (aka location in time), Velocity (Intensity) 

@view
func note_generator{range_check_ptr}(
    site_data_len: felt,
    site_data: felt*,
    out_data_len: felt,
    out_data: felt*,
    arr_idx: felt,
    pitchcollection_len: felt,
    pitchcollection: felt*,
    harmony_table_len: felt,
    harmony_table: felt*,
    randarr_len: felt,
    randarr: felt*,
    randinc: felt,
    drawer_data: HarmonizerInputArgs,
    numharms: felt,
) -> (out_data_len: felt, out_data: felt*) {
    alloc_locals;

    if (numharms == 0) {
        return (out_data_len=out_data_len, out_data=out_data);
    }

    let (numvoicings, _) = unsigned_div_rem(harmony_table_len - 1, harmony_table[0]);
    let (_, harmony_table_index) = unsigned_div_rem(randinc, numvoicings);

    // let (_, harmony_table_index2) = unsigned_div_rem(randinc, randarr_len)

    let rand_idx = randarr[harmony_table_index];

    if (drawer_data.inversion_val == 0) {
        let (newnote) = modal_transposition(
            site_data[arr_idx + 1],
            harmony_table[(rand_idx * harmony_table[0]) + numharms],
            drawer_data.tonic_idx,
            pitchcollection_len,
            pitchcollection,
        );
    } else {
        let (newnote) = modal_transposition_descend(
            site_data[arr_idx + 1],
            harmony_table[(rand_idx * harmony_table[0]) + numharms],
            drawer_data.tonic_idx,
            pitchcollection_len,
            pitchcollection,
        );
    }

    let inc_add = 4;

    let (new_duration, _) = unsigned_div_rem(site_data[arr_idx], drawer_data.num_divisions);

    // Compute Note Attributes

    assert out_data[out_data_len + 0] = new_duration;  // duration
    assert out_data[out_data_len + 1] = newnote;  // new note
    assert out_data[out_data_len + 2] = site_data[arr_idx + 2];  // tick
    assert out_data[out_data_len + 3] = site_data[arr_idx + 3];  // velocity

    let (out_data_len, out_data) = note_generator(
        site_data_len=site_data_len,
        site_data=site_data,
        out_data_len=out_data_len + inc_add,
        out_data=out_data,
        arr_idx=arr_idx,
        pitchcollection_len=pitchcollection_len,
        pitchcollection=pitchcollection,
        harmony_table_len=harmony_table_len,
        harmony_table=harmony_table,
        randarr_len=randarr_len,
        randarr=randarr,
        randinc=randinc,
        drawer_data=drawer_data,
        numharms=numharms - 1,
    );

    return (out_data_len=out_data_len, out_data=out_data);
}


@view
func note_generator_with_inversion{range_check_ptr}(
    site_data_len: felt,
    site_data: felt*,
    out_data_len: felt,
    out_data: felt*,
    arr_idx: felt,
    pitchcollection_len: felt,
    pitchcollection: felt*,
    harmony_table_len: felt,
    harmony_table: felt*,
    randarr_len: felt,
    randarr: felt*,
    randinc: felt,
    drawer_data: HarmonizerInputArgs,
    numharms: felt,
) -> (out_data_len: felt, out_data: felt*) {
    alloc_locals;

    if (numharms == 0) {
        return (out_data_len=out_data_len, out_data=out_data);
    }

    let (numvoicings, _) = unsigned_div_rem(harmony_table_len - 1, harmony_table[0]);
    let (_, harmony_table_index) = unsigned_div_rem(randinc, numvoicings);

    // let (_, harmony_table_index2) = unsigned_div_rem(randinc, randarr_len)
    local diff = is_le(numharms, drawer_data.inversion_val);
    if (numharms == 0) {
    }else{
    }

    let rand_idx = randarr[harmony_table_index];

    // Ensure inversion vals do not exceed nharms
    let (_, inversion_mod) = unsigned_div_rem(drawer_data.inversion_val, numharms);

    // Every index below inversion_mod should be harmonized below, the
   // let (_, n_idx) = unsigned_div_rem(, inversion_mod);


    if (inversion_mod == 0) {
        let (newnote) = modal_transposition(
            site_data[arr_idx + 1],
            harmony_table[(rand_idx * harmony_table[0]) + numharms],
            drawer_data.tonic_idx,
            pitchcollection_len,
            pitchcollection,
        );
    } else {
        let (newnote) = modal_transposition_descend(
            site_data[arr_idx + 1],
            harmony_table[(rand_idx * harmony_table[0]) + numharms],
            drawer_data.tonic_idx,
            pitchcollection_len,
            pitchcollection,
        );
    }

    let inc_add = 4;

    let (new_duration, _) = unsigned_div_rem(site_data[arr_idx], drawer_data.num_divisions);

    // Compute Note Attributes

    assert out_data[out_data_len + 0] = new_duration;  // duration
    assert out_data[out_data_len + 1] = newnote;  // new note
    assert out_data[out_data_len + 2] = site_data[arr_idx + 2];  // tick
    assert out_data[out_data_len + 3] = site_data[arr_idx + 3];  // velocity

    let (out_data_len, out_data) = note_generator_with_inversion(
        site_data_len=site_data_len,
        site_data=site_data,
        out_data_len=out_data_len + inc_add,
        out_data=out_data,
        arr_idx=arr_idx,
        pitchcollection_len=pitchcollection_len,
        pitchcollection=pitchcollection,
        harmony_table_len=harmony_table_len,
        harmony_table=harmony_table,
        randarr_len=randarr_len,
        randarr=randarr,
        randinc=randinc,
        drawer_data=drawer_data,
        numharms=numharms - 1,
    );

    return (out_data_len=out_data_len, out_data=out_data);
}

