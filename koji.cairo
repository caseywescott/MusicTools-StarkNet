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
from autoharmonizer import (harmonization_by_voicing_table, harmonization_by_voicing_table2)


//Contracts recieve input note data and HarmonizerInputArgs, compute harmonies and serialize data for KOJI React MIDI player

@view
func Harmonizer2{syscall_ptr: felt*, range_check_ptr}(site_data_len: felt, site_data: felt*) -> (
    outdata_len: felt, outdata: felt*
) {
    alloc_locals;

    let num_divs = 1;
    let drawer_values = HarmonizerInputArgs(
        site_data[site_data_len - 6],
        site_data[site_data_len - 5],
        site_data[site_data_len - 4],
        site_data[site_data_len - 3],
        site_data[site_data_len - 2],
        site_data[site_data_len - 1],
        site_data_len - 7,
        num_divs,
    );

let val = site_data[site_data_len - 6];

if( val == 0){

    // Two Part Harmonization Function 


  let (local harmony_table_len, local harmony_table) =  two_part_voicing_table();

  let (computed_note_data_len, computed_note_data) = harmonization_by_voicing_table2(
        site_data_len, site_data, drawer_values, harmony_table_len, harmony_table
    );
    return (outdata_len=computed_note_data_len, outdata=computed_note_data);

}

if( val == 1){

    // Three Part Harmonization Function 

  let (local harmony_table_len, local harmony_table) =  three_part_voicing_table();

  let (computed_note_data_len, computed_note_data) = harmonization_by_voicing_table2(
        site_data_len, site_data, drawer_values, harmony_table_len, harmony_table
    );
    return (outdata_len=computed_note_data_len, outdata=computed_note_data);

}

if( val == 2){

    // Ravel Harmonization Function 

  let (local harmony_table_len, local harmony_table) =  ravel_string_quartet_voicing_table();

  let (computed_note_data_len, computed_note_data) = harmonization_by_voicing_table2(
        site_data_len, site_data, drawer_values, harmony_table_len, harmony_table
    );
    return (outdata_len=computed_note_data_len, outdata=computed_note_data);

}else{

    // Call the Disklavier Function in Player 

  let (local harmony_table_len2, local harmony_table2) =  three_part_voicing_table();

    let (local new_arr: felt*) = alloc();

  let (computed_note_data_len, computed_note_data) = realms_disklavier(drawer_values);
    return (outdata_len=computed_note_data_len, outdata=computed_note_data);

}

}



