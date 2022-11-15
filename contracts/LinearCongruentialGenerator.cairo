%lang starknet
%builtins pedersen range_check

from starkware.starknet.common.syscalls import get_block_number
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_nn, is_le, is_not_zero
from starkware.cairo.common.math import unsigned_div_rem, assert_nn

//*******************************************************************************************************************
// Implementation of Pseudorandom Number Generator for the purpose of creating musical variation
//
// https://en.wikipedia.org/wiki/Linear_congruential_generator 
// AKA => 'LCG'
// The generator is defined by the recurrence relation:
// randomNums[i] = ((randomNums[i – 1] * a) + c) % m
//
// where X is the sequence of pseudo-random values, and
//
// m, 0 < m      — the "modulus"
// a, 0 < a < m  — the "multiplier"
// c, 0 < c < m — the "increment"
// X_0,0 < X_0 < m — the "seed" or "start value"
//
// This implementation uses the current block number as the seed
// We can use the seed in a LCG to generate different musical, rhythmic and harmonic variation 
// Specifically, LCG values can be used index into Voicing / Intervallic Tables used to transpose/harmonize notes 
//
// The following functions recieve an array and populates with a pseudo-random number sequence for arr_size 
//*******************************************************************************************************************

// Internal iterator function for Linear Congruence Generator with offset input

@view
func block_num{syscall_ptr: felt*, range_check_ptr}() -> (curr_block: felt) {
    let (curr_block) = get_block_number();
    return (curr_block=curr_block);
}

@view
func lcg_inner{range_check_ptr}(
    arr_len: felt, arr: felt*, arr_size: felt, modulus: felt, mult: felt, seed: felt, offset: felt
) {
    alloc_locals;

    if (arr_len == arr_size) {
        return ();
    }

    let (_, local val) = unsigned_div_rem((seed * mult) + arr_len, modulus);

    assert arr[arr_len] = val + offset;

    lcg_inner(
        arr_len=arr_len + 1,
        arr=arr,
        arr_size=arr_size,
        modulus=modulus,
        mult=mult,
        seed=val,
        offset=offset,
    );

    return ();
}

// Provide and populate array using LCG with offset arg and seeded by the current block number

@view
func get_lcg_list_with_offset{syscall_ptr: felt*, range_check_ptr}(
    arr_size: felt, modulus: felt, mult: felt, offset: felt
) -> (arr_len: felt, arr: felt*) {
    alloc_locals;

    let (curr_block) = get_block_number();

    let (local new_arr: felt*) = alloc();

    lcg_inner(0, new_arr, arr_size, modulus, mult, curr_block, offset);

    return (arr_len=arr_size, arr=new_arr);
}

// Provide and populate array using LCG with offset and upper boundary args, seeded by the current block number
// Useful for varied selection of voicings within a given Voicing Table size

@view
func get_lcg_list_with_bounds{syscall_ptr: felt*, range_check_ptr}(
    arr_size: felt, modulus: felt, mult: felt, offset: felt
) -> (arr_len: felt, arr: felt*) {
    alloc_locals;

    let (curr_block) = get_block_number();

    let (local new_arr: felt*) = alloc();

    lcg_inner(0, new_arr, arr_size, modulus - offset, mult, curr_block, offset);

    return (arr_len=arr_size, arr=new_arr);
}

// generate bounded LCG with seed included as argument
// Useful for creating ranges od Voicing Table indexes

@view
func get_lcg_list_with_bounds_seed{range_check_ptr}(
    arr_size: felt, modulus: felt, mult: felt, offset: felt, seed: felt
) -> (arr_len: felt, arr: felt*) {
    alloc_locals;

    let (local new_arr: felt*) = alloc();

    lcg_inner(0, new_arr, arr_size, modulus - offset, mult, seed, offset);

    return (arr_len=arr_size, arr=new_arr);
}