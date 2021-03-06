target=//androidAppModule0
bazel=/tmp/bazel-bin/src/bazel

common_flags=--profile=$@.prof
dump_raw_profile=analyze-profile $@.prof --dump=raw > $@.prof.raw
analyze_profile=./analyze-profile.py --mode duration_by_action_type $@.prof.raw > $@.prof.csv

clean: FORCE
	$(bazel) clean

analysis: clean
	$(bazel) build $(target) --nobuild

control: clean
	$(bazel) build $(target) $(common_flags)

rbe-javabase-issue:
	$(bazel) build $(target) --config=javabase_linking_issue $(common_flags)

rbe:
	$(bazel) build $(target) --config=remote --config=results $(common_flags)

rbe-hybrid:
	$(bazel) build $(target) --config=remote --config=results --strategy_regexp="Desugaring.*"=standalone --strategy_regexp="Extracting.*"=standalone --strategy_regexp="Merging.*"=standalone $(common_flags)

aapt2: clean
	$(bazel) build $(target) --android_aapt=aapt2 $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

aapt2-incremental-change:
	$(bazel) build $(target) --android_aapt=aapt2 $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

aapt2-with-all-workers: clean
	$(bazel) build $(target) --android_aapt=aapt2 --persistent_android_resource_processor --worker_max_instances=2 --strategy=DexBuilder=worker $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

aapt2-with-all-workers-incremental-change:
	$(bazel) build $(target) --android_aapt=aapt2 --persistent_android_resource_processor --worker_max_instances=2 --strategy=DexBuilder=worker $(common_flags)
	$(bazel) $(dump_raw_profile)
	$(analyze_profile)

FORCE: ;
