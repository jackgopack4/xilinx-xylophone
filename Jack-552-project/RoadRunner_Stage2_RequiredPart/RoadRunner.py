#!/usr/bin/env python
import re, argparse, os, subprocess, sys, shutil

UNTAR = "rm -rf %(src_dir)s/ && mkdir %(src_dir)s/ && tar xvzf %(tar_dir)s/%(tar_file)s -C %(src_dir)s/"
ASSEMBLER = "./asmbl.pl %(program_dir)s/%(program_src)s"
LIBRARY = {"vvp": ":", "vsim": "rm -rf ./my_lib/ && vlib my_lib && vmap work ./my_lib/"}
COMPILER = {"vvp": "iverilog -Wall -o %(src_dir)s/%(vvp_binary)s -I %(src_dir)s -s clk_and_rst_n %(src_dir)s/*.v", "vsim": "touch %(src_dir)s/RoadRunner.sv && touch %(src_dir)s/RoadRunner.vs && vlog +incdir+%(src_dir)s %(src_dir)s/*.v %(src_dir)s/*.sv %(src_dir)s/*.vs"}
SIMULATOR = {"vvp": "vvp %(src_dir)s/%(vvp_binary)s", "vsim": "vsim -c -novopt work.clk_and_rst_n -do 'run -a; q'"}
DEFAULT_PROGRAM_BINARY = 'instr.hex'
DEFAULT_RESULTS_FILE = 'RoadRunner_results.txt'
SIM_OUT_REGEX = re.compile("^#?\s?R0*1 = ([0-9a-zA-Z]{4})\s#?\s?R0*2 = ([0-9a-zA-Z]{4})\s#?\s?R0*3 = ([0-9a-zA-Z]{4})\s#?\s?R0*4 = ([0-9a-zA-Z]{4})\s#?\s?R0*5 = ([0-9a-zA-Z]{4})\s#?\s?R0*6 = ([0-9a-zA-Z]{4})\s#?\s?R0*7 = ([0-9a-zA-Z]{4})\s#?\s?R0*8 = ([0-9a-zA-Z]{4})\s#?\s?R0*9 = ([0-9a-zA-Z]{4})\s#?\s?R0*a = ([0-9a-zA-Z]{4})\s#?\s?R0*b = ([0-9a-zA-Z]{4})\s#?\s?R0*c = ([0-9a-zA-Z]{4})\s#?\s?R0*d = ([0-9a-zA-Z]{4})\s#?\s?R0*e = ([0-9a-zA-Z]{4})\s#?\s?R0*f = ([0-9a-zA-Z]{4})\s.*\s#?\s?Cycles:\s*(\d*)\s#?\s?PC:\s*([0-9a-zA-Z]*)$", re.MULTILINE)
SIM_OUT_REGEX_NO_PC = re.compile("^#?\s?R0*1 = ([0-9a-zA-Z]{4})\s#?\s?R0*2 = ([0-9a-zA-Z]{4})\s#?\s?R0*3 = ([0-9a-zA-Z]{4})\s#?\s?R0*4 = ([0-9a-zA-Z]{4})\s#?\s?R0*5 = ([0-9a-zA-Z]{4})\s#?\s?R0*6 = ([0-9a-zA-Z]{4})\s#?\s?R0*7 = ([0-9a-zA-Z]{4})\s#?\s?R0*8 = ([0-9a-zA-Z]{4})\s#?\s?R0*9 = ([0-9a-zA-Z]{4})\s#?\s?R0*a = ([0-9a-zA-Z]{4})\s#?\s?R0*b = ([0-9a-zA-Z]{4})\s#?\s?R0*c = ([0-9a-zA-Z]{4})\s#?\s?R0*d = ([0-9a-zA-Z]{4})\s#?\s?R0*e = ([0-9a-zA-Z]{4})\s#?\s?R0*f = ([0-9a-zA-Z]{4})\s.*\s#?\s?Cycles:\s*(\d*)$", re.MULTILINE)
SIM_OUT_COUNT = 17
TAR_FILE_SUFFIX = ('.tar.gz', '.tgz')
PROVIDED_MODULES_SUFFIX = '.v'
PROGRAM_SRC_SUFFIX = ('.txt', '.asm')
PROGRAM_BINARY_SUFFIX = '.bin'
SIM_OUT_SUFFIX = '.sim_out'
DEBUG_MODE = True

def parse_cmd_line_args():
	parser = argparse.ArgumentParser(description='WISC_F14 functional and performance simulation script')
	parser.add_argument('--sim', type=str, required=False, choices=['vvp', 'vsim', 'hybrid'], default='hybrid', dest='sim', help='Simulator to use')
	parser.add_argument('--program_dir', type=str, required=False, default='programs', dest='program_dir', help='Test program source directory')
	parser.add_argument('--program_src', type=str, required=False, default=None, dest='program_src', help='Test program source file')
	parser.add_argument('--program_binary', type=str, required=False, default=None, dest='program_binary', help='Test program binary file')
	parser.add_argument('--provided_modules_dir', type=str, required=False, default='provided_modules', dest='provided_modules_dir', help='Directory containing the provided modules like cache, etc.')
	parser.add_argument('--ref_src_dir', type=str, required=False, default='ref', dest='ref_src_dir', help='WISC_F14 reference model source directory')
	parser.add_argument('--ref_vvp_binary', type=str, required=False, default='WISC.F14', dest='ref_vvp_binary', help='WISC_F14 reference model vvp binary file')
	parser.add_argument('--ref_sim_out', type=str, required=False, default='ref.sim_out', dest='ref_sim_out', help='WISC_F14 reference model simulation output file')
	parser.add_argument('--dut_tar_dir', type=str, required=False, default='tars_dir', dest='dut_tar_dir', help='DUT models tar directory')
	parser.add_argument('--dut_tar_file', type=str, required=False, default=None, dest='dut_tar_file', help='DUT model tar file')
	parser.add_argument('--dut_src_dir', type=str, required=False, default='dut', dest='dut_src_dir', help='DUT model source directory')
	parser.add_argument('--dut_vvp_binary', type=str, required=False, default='a.out', dest='dut_vvp_binary', help='DUT model vvp binary file')
	parser.add_argument('--dut_sim_out', type=str, required=False, default='dut.sim_out', dest='dut_sim_out', help='DUT model simulation output file')
	parser.add_argument('--no_func', action='store_true', required=False, default=False, dest='no_func', help='Flag to disable functional testing')
	parser.add_argument('--no_perf', action='store_true', required=False, default=False, dest='no_perf', help='Flag to disable performance testing')
	parser.add_argument('--ignore_pc', action='store_true', required=False, default=False, dest='ignore_pc', help='Flag to ignore final PC value during func/perf testing')
	parser.add_argument('--no_debug', action='store_true', required=False, default=False, dest='no_debug', help='Flag to disable debug messages')
	cmd_line_args = parser.parse_args()
	return cmd_line_args

def print_debug_message(debug_message, debug_tuple=()):
	if DEBUG_MODE:
		print debug_message % debug_tuple
	return

def check_if_multiple_duts(tar_dir):
	if tar_dir and os.path.exists(tar_dir) and os.path.isdir(tar_dir):
		return True
	return False

def get_tars_list(tar_dir):
	return [tar_file for tar_file in os.listdir(tar_dir) if tar_file.endswith(TAR_FILE_SUFFIX)]

def check_if_tar_file_exists(tar_file):
	if tar_file and tar_file.endswith(TAR_FILE_SUFFIX) and os.path.exists(tar_file) and os.path.isfile(tar_file):
		return True
	return False

def extract_tar_file(tar_dir, tar_file, src_dir):
	with open(os.devnull, 'w') as fp:
		try:
			subprocess.check_call(UNTAR % {"src_dir": src_dir, "tar_dir": tar_dir, "tar_file": tar_file}, stdout=fp, stderr=fp, shell=True)
		except:
			return None
		else:
			return True

def check_if_multiple_programs(program_dir, program_src, program_binary):
	if program_binary is not None:
		return False
	if program_src is not None:
		return False
	if os.path.exists(program_dir) and os.path.isdir(program_dir):
		return True
	return None

def get_programs_list(program_dir):
	return [program_file for program_file in os.listdir(program_dir) if program_file.endswith(PROGRAM_SRC_SUFFIX)]

def create_results_file(src_dir):
	if src_dir and os.path.exists(src_dir) and os.path.isdir(src_dir):
		open(os.path.join(src_dir, DEFAULT_RESULTS_FILE), 'w').write('')
		return True
	return False

def make_program_binary(program_dir, program_src, program_binary):
	if program_binary:
		if os.path.exists(os.path.join(program_dir, program_binary)):
			if program_src is None:
				return os.path.join(program_dir, program_binary)
			elif os.path.exists(os.path.join(program_dir, program_src)) and os.path.getmtime(os.path.join(program_dir, program_binary)) > os.path.getmtime(os.path.join(program_dir, program_src)):
				return os.path.join(program_dir, program_binary)
	if program_src:
		if os.path.exists(os.path.join(program_dir, program_src)):
			if not program_binary:
				program_binary = DEFAULT_PROGRAM_BINARY
			with open(os.path.join(program_dir, program_binary), 'w') as fp:
				try:
					subprocess.check_call(ASSEMBLER % {"program_dir":program_dir, "program_src":program_src}, stdout=fp, stderr=fp, shell=True)
				except:
					return None
				else:
					return os.path.join(program_dir, program_binary)
	return None

def relocate_program_binary(program_binary_path, dest_dir1, dest_dir2):
	ret_val1 = None
	ret_val2 = None
	if program_binary_path is None:
		return (ret_val1, ret_val2)
	if os.path.exists(dest_dir1) and os.path.isdir(dest_dir1):
		if os.path.abspath(program_binary_path) != os.path.abspath(os.path.join(dest_dir1, DEFAULT_PROGRAM_BINARY)):
			shutil.copyfile(program_binary_path, os.path.join(dest_dir1, DEFAULT_PROGRAM_BINARY))
		ret_val1 = True
	if os.path.exists(dest_dir2) and os.path.isdir(dest_dir2):
		if os.path.abspath(program_binary_path) != os.path.abspath(os.path.join(dest_dir2, DEFAULT_PROGRAM_BINARY)):
			shutil.copyfile(program_binary_path, os.path.join(dest_dir2, DEFAULT_PROGRAM_BINARY))
		ret_val2 = True
	return (ret_val1, ret_val2)

def relocate_program_binary_to_cwd(program_binary_path, dest_dir):
	if program_binary_path is None:
		return None
	if os.path.exists(dest_dir) and os.path.isdir(dest_dir):
		if os.path.abspath(program_binary_path) != os.path.abspath(os.path.join(dest_dir, DEFAULT_PROGRAM_BINARY)):
			shutil.copyfile(program_binary_path, os.path.join(dest_dir, DEFAULT_PROGRAM_BINARY))
		return True
	return None

def make_vvp_binary(src_dir, vvp_binary, is_dut):
	if not is_dut:
		if os.path.exists(os.path.join(src_dir, vvp_binary)):
			return os.path.join(src_dir, vvp_binary)
	if os.path.exists(src_dir) and os.path.isdir(src_dir):
		with open(os.path.join(src_dir, vvp_binary), 'w') as fp:
				try:
					subprocess.check_call(COMPILER['vvp'] % {"src_dir": src_dir, "vvp_binary": vvp_binary}, stdout=fp, stderr=fp, shell=True)
				except:
					return None
				else:
					return os.path.join(src_dir, vvp_binary)
	return None

def overwrite_files(src_dir, dest_dir):
	if src_dir and os.path.exists(src_dir) and os.path.isdir(src_dir) and dest_dir and os.path.exists(dest_dir) and os.path.isdir(dest_dir) and os.path.abspath(src_dir) != os.path.abspath(dest_dir):
		for filename in os.listdir(src_dir):
			if filename.endswith(PROVIDED_MODULES_SUFFIX):
				shutil.copy(os.path.join(src_dir, filename), dest_dir)
		return True
	return False

def library_vsim():
	with open(os.devnull, 'w') as fp:
		try:
			subprocess.check_call(LIBRARY["vsim"], stdout=fp, stderr=fp, shell=True)
		except:
			return None
		else:
			return True

def compile_vsim(src_dir):
	if src_dir and os.path.exists(src_dir) and os.path.isdir(src_dir):
		with open(os.devnull, 'w') as fp:
			try:
				subprocess.check_call(COMPILER['vsim'] % {"src_dir": src_dir}, stdout=fp, stderr=fp, shell=True)
			except:
				return None
			else:
				return True
	return None

def make_vvp_sim_out(src_dir, vvp_binary, sim_out):
	if not src_dir:
		return None
	if os.path.exists(os.path.join(src_dir, vvp_binary)) and os.path.isdir(src_dir):
		with open(os.path.join(src_dir, sim_out), 'w') as fp:
				try:
					subprocess.check_call(SIMULATOR['vvp'] % {"src_dir": src_dir, "vvp_binary": vvp_binary}, stdout=fp, stderr=fp, shell=True)
				except:
					return None
				else:
					return os.path.join(src_dir, sim_out)
	return None

def simulate_vsim(src_dir, sim_out):
	if src_dir and os.path.exists(src_dir) and os.path.isdir(src_dir):
		with open(os.path.join(src_dir, sim_out), 'w') as fp:
			try:
				subprocess.check_call(SIMULATOR['vsim'], stdout=fp, stderr=fp, shell=True)
			except:
				return None
			else:
				return os.path.join(src_dir, sim_out)
	return None

def parse_sim_out(ref_sim_out, dut_sim_out, ignore_pc):
	regex_pattern = ignore_pc and SIM_OUT_REGEX_NO_PC or SIM_OUT_REGEX
	groups_count = ignore_pc and (SIM_OUT_COUNT - 1) or SIM_OUT_COUNT
	if ref_sim_out and os.path.exists(ref_sim_out) and dut_sim_out and os.path.exists(dut_sim_out):
		with open(ref_sim_out) as fp:
			ref_sim_result = regex_pattern.search(fp.read())
		with open(dut_sim_out) as fp:
			dut_sim_result = regex_pattern.search(fp.read())
		if not ref_sim_result or not dut_sim_result or len(ref_sim_result.groups()) != len(dut_sim_result.groups()) or len(ref_sim_result.groups()) != groups_count:
			return (False, False)
		return (ref_sim_result, dut_sim_result)
	return (False, False)

def get_functional_result(ref_sim_out, dut_sim_out, ignore_pc):
	(ref_sim_result, dut_sim_result) = parse_sim_out(ref_sim_out, dut_sim_out, ignore_pc)
	if ref_sim_result and dut_sim_result:
		for index in range(1, len(ref_sim_result.groups())+1):
			if index == 16: continue							#Cycles is in index 16
			if ref_sim_result.group(index) != dut_sim_result.group(index):
				return False
		return True
	return False

def get_performance_result(ref_sim_out, dut_sim_out, ignore_pc):
	(ref_sim_result, dut_sim_result) = parse_sim_out(ref_sim_out, dut_sim_out, ignore_pc)
	if ref_sim_result and dut_sim_result:
		return {"ref_cycles": int(ref_sim_result.group(16)), "dut_cycles": int(dut_sim_result.group(16))}
	return None

def vvp_road_runner(cmd_line_args):
	functional_test_result = None
	performance_test_result = None
	program_binary_path = make_program_binary(cmd_line_args.program_dir, cmd_line_args.program_src, cmd_line_args.program_binary)
	relocation_ret_val = relocate_program_binary(program_binary_path, cmd_line_args.ref_src_dir, cmd_line_args.dut_src_dir)
	relocation_ret_val = relocate_program_binary_to_cwd(program_binary_path, '.')
	ref_vvp_binary_path = make_vvp_binary(cmd_line_args.ref_src_dir, cmd_line_args.ref_vvp_binary, False)
	ref_vvp_sim_out_path = make_vvp_sim_out(cmd_line_args.ref_src_dir, cmd_line_args.ref_vvp_binary, cmd_line_args.ref_sim_out)
	dut_overwrite_files = overwrite_files(cmd_line_args.provided_modules_dir, cmd_line_args.dut_src_dir)
	dut_vvp_binary_path = make_vvp_binary(cmd_line_args.dut_src_dir, cmd_line_args.dut_vvp_binary, True)
	dut_vvp_sim_out_path = make_vvp_sim_out(cmd_line_args.dut_src_dir, cmd_line_args.dut_vvp_binary, cmd_line_args.dut_sim_out)
	if program_binary_path and ref_vvp_binary_path and ref_vvp_sim_out_path and dut_vvp_binary_path and dut_vvp_sim_out_path:
		if not cmd_line_args.no_func:
			functional_test_result = get_functional_result(ref_vvp_sim_out_path, dut_vvp_sim_out_path, cmd_line_args.ignore_pc)
		if not cmd_line_args.no_perf:
			performance_test_result = get_performance_result(ref_vvp_sim_out_path, dut_vvp_sim_out_path, cmd_line_args.ignore_pc)
	else:
		print_debug_message("\t\tERROR - One or more steps failed during execution:")
		print_debug_message("\t\t\tProgram binary - %s", (program_binary_path))
		print_debug_message("\t\t\tReference vvp compilation - %s", (ref_vvp_binary_path))
		print_debug_message("\t\t\tReference vvp simulation - %s", (ref_vvp_sim_out_path))
		print_debug_message("\t\t\tDUT vvp compilation - %s", (dut_vvp_binary_path))
		print_debug_message("\t\t\tDUT vvp simulation - %s", (dut_vvp_sim_out_path))
	return {"func": functional_test_result, "perf": performance_test_result}

def vsim_road_runner(cmd_line_args):
	functional_test_result = None
	performance_test_result = None
	program_binary_path = make_program_binary(cmd_line_args.program_dir, cmd_line_args.program_src, cmd_line_args.program_binary)
	relocation_ret_val = relocate_program_binary(program_binary_path, cmd_line_args.ref_src_dir, cmd_line_args.dut_src_dir)
	relocation_ret_val = relocate_program_binary_to_cwd(program_binary_path, '.')
	ref_library_vsim = library_vsim()
	ref_compile_vsim = compile_vsim(cmd_line_args.ref_src_dir)
	ref_simulate_vsim = simulate_vsim(cmd_line_args.ref_src_dir, cmd_line_args.ref_sim_out)
	dut_overwrite_files = overwrite_files(cmd_line_args.provided_modules_dir, cmd_line_args.dut_src_dir)
	dut_library_vsim = library_vsim()
	dut_compile_vsim = compile_vsim(cmd_line_args.dut_src_dir)
	dut_simulate_vsim = simulate_vsim(cmd_line_args.dut_src_dir, cmd_line_args.dut_sim_out)
	if program_binary_path and ref_library_vsim and ref_compile_vsim and ref_simulate_vsim and dut_library_vsim and dut_compile_vsim and dut_simulate_vsim:
		if not cmd_line_args.no_func:
			functional_test_result = get_functional_result(ref_simulate_vsim, dut_simulate_vsim, cmd_line_args.ignore_pc)
		if not cmd_line_args.no_perf:
			performance_test_result = get_performance_result(ref_simulate_vsim, dut_simulate_vsim, cmd_line_args.ignore_pc)
	else:
		print_debug_message("\t\tERROR - One or more steps failed during execution:")
		print_debug_message("\t\t\tProgram binary - %s", (program_binary_path))
		print_debug_message("\t\t\tReference vsim library creation - %s", (ref_library_vsim))
		print_debug_message("\t\t\tReference vsim compilation - %s", (ref_compile_vsim))
		print_debug_message("\t\t\tReference vsim simulation - %s", (ref_simulate_vsim))
		print_debug_message("\t\t\tDUT vsim library creation - %s", (dut_library_vsim))
		print_debug_message("\t\t\tDUT vsim compilation - %s", (dut_compile_vsim))
		print_debug_message("\t\t\tDUT vsim simulation - %s", (dut_simulate_vsim))
	return {"func": functional_test_result, "perf": performance_test_result}

def hybrid_road_runner(cmd_line_args):
	functional_test_result = None
	performance_test_result = None
	program_binary_path = make_program_binary(cmd_line_args.program_dir, cmd_line_args.program_src, cmd_line_args.program_binary)
	relocation_ret_val = relocate_program_binary(program_binary_path, cmd_line_args.ref_src_dir, cmd_line_args.dut_src_dir)
	relocation_ret_val = relocate_program_binary_to_cwd(program_binary_path, '.')
	ref_vvp_binary_path = make_vvp_binary(cmd_line_args.ref_src_dir, cmd_line_args.ref_vvp_binary, False)
	ref_vvp_sim_out_path = make_vvp_sim_out(cmd_line_args.ref_src_dir, cmd_line_args.ref_vvp_binary, cmd_line_args.ref_sim_out)
	dut_overwrite_files = overwrite_files(cmd_line_args.provided_modules_dir, cmd_line_args.dut_src_dir)
	dut_library_vsim = library_vsim()
	dut_compile_vsim = compile_vsim(cmd_line_args.dut_src_dir)
	dut_simulate_vsim = simulate_vsim(cmd_line_args.dut_src_dir, cmd_line_args.dut_sim_out)
	if program_binary_path and ref_vvp_binary_path and ref_vvp_sim_out_path and dut_library_vsim and dut_compile_vsim and dut_simulate_vsim:
		if not cmd_line_args.no_func:
			functional_test_result = get_functional_result(ref_vvp_sim_out_path, dut_simulate_vsim, cmd_line_args.ignore_pc)
		if not cmd_line_args.no_perf:
			performance_test_result = get_performance_result(ref_vvp_sim_out_path, dut_simulate_vsim, cmd_line_args.ignore_pc)
	else:
		print_debug_message("\t\tERROR - One or more steps failed during execution:")
		print_debug_message("\t\t\tProgram binary - %s", (program_binary_path))
		print_debug_message("\t\t\tReference vvp compilation - %s", (ref_vvp_binary_path))
		print_debug_message("\t\t\tReference vvp simulation - %s", (ref_vvp_sim_out_path))
		print_debug_message("\t\t\tDUT vsim library creation - %s", (dut_library_vsim))
		print_debug_message("\t\t\tDUT vsim compilation - %s", (dut_compile_vsim))
		print_debug_message("\t\t\tDUT vsim simulation - %s", (dut_simulate_vsim))
	return {"func": functional_test_result, "perf": performance_test_result}

def log_result(src_dir, result, program="unknown"):
	if src_dir and os.path.exists(src_dir) and os.path.isdir(src_dir):
		with open(os.path.join(src_dir, DEFAULT_RESULTS_FILE), 'a') as fp:
			fp.write('%s, %s' % (program, result["func"] and "pass" or "fail"))
			if result["func"]:
				fp.write(', %s, %s' % (str(result["perf"]["dut_cycles"]), str(result["perf"]["ref_cycles"])))
			fp.write('\n')
		return True
	return None

def road_runner(cmd_line_args):
	is_multiple_programs = check_if_multiple_programs(cmd_line_args.program_dir, cmd_line_args.program_src, cmd_line_args.program_binary)
	if is_multiple_programs is None:
		print_debug_message("\tERROR - Assembly programs directory invalid!")
		return False
	elif is_multiple_programs:
		programs_list = get_programs_list(cmd_line_args.program_dir)
		print_debug_message("\tFound a list of programs (.txt or .asm extensions only) - %s", programs_list)
		create_results_file(cmd_line_args.dut_src_dir)
		for program in programs_list:
			cmd_line_args.program_src = program
			cmd_line_args.program_binary = program + PROGRAM_BINARY_SUFFIX
			cmd_line_args.ref_sim_out = program + '_ref' + SIM_OUT_SUFFIX
			cmd_line_args.dut_sim_out = program + '_dut' + SIM_OUT_SUFFIX
			if cmd_line_args.sim == "hybrid":
				print_debug_message("\t\tExecuting %s in hybrid (ref-vvp, dut-vsim) simulation mode" % (program))
				result = hybrid_road_runner(cmd_line_args)
			elif cmd_line_args.sim == "vvp":
				print_debug_message("\t\tExecuting %s in vvp (ref-vvp, dut-vvp) simulation mode" % (program))
				result = vvp_road_runner(cmd_line_args)
			elif cmd_line_args.sim == "vsim":
				print_debug_message("\t\tExecuting %s in vsim (ref-vsim, dut-vsim) simulation mode" % (program))
				result = vsim_road_runner(cmd_line_args)
			else:
				return False
			print_debug_message("\t\tLogging %s execution result to %s file in %s directory", (program, DEFAULT_RESULTS_FILE, cmd_line_args.dut_src_dir))
			log_result(cmd_line_args.dut_src_dir, result, program)
	else:
		create_results_file(cmd_line_args.dut_src_dir)
		if cmd_line_args.sim == "hybrid":
			print_debug_message("\tExecuting in hybrid (ref-vvp, dut-vsim) simulation mode")
			result = hybrid_road_runner(cmd_line_args)
		elif cmd_line_args.sim == "vvp":
			print_debug_message("\tExecuting in vvp (ref-vvp, dut-vvp) simulation mode")
			result = vvp_road_runner(cmd_line_args)
		elif cmd_line_args.sim == "vsim":
			print_debug_message("\tExecuting in vsim (ref-vsim, dut-vsim) simulation mode")
			result = vsim_road_runner(cmd_line_args)
		else:
			return False
		print_debug_message("\tLogging execution result to %s file in %s directory", (DEFAULT_RESULTS_FILE, cmd_line_args.dut_src_dir))
		log_result(cmd_line_args.dut_src_dir, result)
	return True

if __name__ == "__main__":
	cmd_line_args = parse_cmd_line_args()
	if cmd_line_args.no_debug:
		DEBUG_MODE = False
	is_multiple_duts = check_if_multiple_duts(cmd_line_args.dut_tar_dir)
	is_tar_file = check_if_tar_file_exists(cmd_line_args.dut_tar_file)
	if is_multiple_duts:
		print_debug_message("Processing directory %s of DUT tar files", (cmd_line_args.dut_tar_dir))
		original_program_src = cmd_line_args.program_src
		original_program_binary = cmd_line_args.program_binary
		tars_list = get_tars_list(cmd_line_args.dut_tar_dir)
		for tar_file in tars_list:
			cmd_line_args.dut_src_dir = tar_file + '_extracted'
			print_debug_message("\tExtracting DUT tar file %s into %s", (tar_file, cmd_line_args.dut_src_dir))
			untar_ret_val = extract_tar_file(cmd_line_args.dut_tar_dir, tar_file, cmd_line_args.dut_src_dir)
			if untar_ret_val:
				road_runner_ret_val = road_runner(cmd_line_args)
			cmd_line_args.program_src = original_program_src
			cmd_line_args.program_binary = original_program_binary
	elif is_tar_file:
		print_debug_message("Processing DUT tar file %s", (cmd_line_args.dut_tar_file))
		cmd_line_args.dut_src_dir = cmd_line_args.dut_tar_file + '_extracted'
		print_debug_message("Extracting into %s", (cmd_line_args.dut_src_dir))
		untar_ret_val = extract_tar_file('.', cmd_line_args.dut_tar_file, cmd_line_args.dut_src_dir)
		if untar_ret_val:
			road_runner_ret_val = road_runner(cmd_line_args)
	else:
		print_debug_message("Processing DUT source directory %s", (cmd_line_args.dut_src_dir))
		road_runner_ret_val = road_runner(cmd_line_args)
