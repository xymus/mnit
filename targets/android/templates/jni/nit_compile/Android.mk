# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_NIT_DIR := ../out/nit/
LOCAL_MNIT_DIR := ../out/mnit/

LOCAL_CFLAGS	:= -I $(NIT_DIR)/clib/ \
				   -D ANDROID \
				   -I $(MNIT_DIR)/src/android/ \
				   -I $(LOCAL_PATH) \
				   -I $(LOCAL_PATH)/../libpng/ \
				   -I $(LOCAL_PATH)/../libftgles/ \
				   -Wall -Wextra -Wformat-security -Wcast-align -Wno-uninitialized -Wno-unused-variable -Wno-unused-label -Wno-unused-parameter -Wno-missing-field-initializers

LOCAL_MODULE    := main
LOCAL_SRC_FILES := \
	$(subst $(LOCAL_PATH)/,, \
		$(wildcard $(LOCAL_PATH)/*.c) \
		$(wildcard $(LOCAL_PATH)/$(LOCAL_MNIT_DIR)/src/mnit/*.c ) \
		$(wildcard $(LOCAL_PATH)/$(LOCAL_MNIT_DIR)/src/android/*.c ) \
		$(wildcard $(LOCAL_PATH)/$(LOCAL_NIT_DIR)/clib/*.c ) \
		$(wildcard $(LOCAL_PATH)/$(LOCAL_NIT_DIR)/lib/standard/*.c ) )
LOCAL_LDLIBS    := -llog -landroid -lEGL -lGLESv1_CM -lz
LOCAL_STATIC_LIBRARIES := android_native_app_glue libpng

include $(BUILD_SHARED_LIBRARY)

$(call import-module,android/native_app_glue)

