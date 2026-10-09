platform :ios, '17.0'

use_frameworks! :linkage => :static
inhibit_all_warnings!

target 'Learning_prepositions_is_easy' do
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Storage'
end

target 'Learning_prepositions_is_easyTests' do
  inherit! :search_paths
end

# Xcode 26 scans both #if SWIFT_PACKAGE branches in Firebase, so CocoaPods
# builds fail looking for SPM module names like GoogleUtilities_NSData.
def write_google_utilities_shims(pods_root)
  require 'fileutils'
  shim_dir = File.join(pods_root, 'GoogleUtilitiesShims')
  FileUtils.mkdir_p(shim_dir)
  gul = File.join(pods_root, 'GoogleUtilities', 'GoogleUtilities')

  modules = {
    'GoogleUtilities_NSData' => [
      'NSData+zlib/Public/GoogleUtilities/GULNSData+zlib.h'
    ],
    'GoogleUtilities_Environment' => [
      'Environment/Public/GoogleUtilities/GULAppEnvironmentUtil.h',
      'Environment/Public/GoogleUtilities/GULKeychainStorage.h',
      'Environment/Public/GoogleUtilities/GULKeychainUtils.h',
      'Environment/Public/GoogleUtilities/GULNetworkInfo.h'
    ],
    'GoogleUtilities_UserDefaults' => [
      'UserDefaults/Public/GoogleUtilities/GULUserDefaults.h'
    ],
    'GoogleUtilities_AppDelegateSwizzler' => [
      'AppDelegateSwizzler/Public/GoogleUtilities/GULAppDelegateSwizzler.h',
      'AppDelegateSwizzler/Public/GoogleUtilities/GULSceneDelegateSwizzler.h',
      'AppDelegateSwizzler/Public/GoogleUtilities/GULApplication.h'
    ],
    'GoogleUtilities_Logger' => [
      'Logger/Public/GoogleUtilities/GULLogger.h',
      'Logger/Public/GoogleUtilities/GULLoggerLevel.h'
    ],
    'GoogleUtilities_Network' => [
      'Network/Public/GoogleUtilities/GULNetwork.h',
      'Network/Public/GoogleUtilities/GULNetworkConstants.h',
      'Network/Public/GoogleUtilities/GULNetworkLoggerProtocol.h',
      'Network/Public/GoogleUtilities/GULNetworkURLSession.h',
      'Network/Public/GoogleUtilities/GULMutableDictionary.h',
      'Network/Public/GoogleUtilities/GULNetworkMessageCode.h'
    ],
    'GoogleUtilities_Reachability' => [
      'Reachability/Public/GoogleUtilities/GULReachabilityChecker.h'
    ],
    'GoogleUtilities_MethodSwizzler' => [
      'MethodSwizzler/Public/GoogleUtilities/GULSwizzler.h',
      'MethodSwizzler/Public/GoogleUtilities/GULOriginalIMPConvenienceMacros.h'
    ]
  }

  combined = modules.map do |name, headers|
    existing = headers.select { |rel| File.exist?(File.join(gul, rel)) }
    header_lines = existing.map { |rel| "  header \"#{File.join(gul, rel)}\"" }.join("\n")
    body = <<~M
      module #{name} {
      #{header_lines}
        export *
      }
    M
    File.write(File.join(shim_dir, "#{name}.modulemap"), body)
    body
  end.join("\n")

  File.write(File.join(shim_dir, 'module.modulemap'), combined)
end

def append_shim_search_paths(config)
  shim_flag = '-fmodule-map-file="${PODS_ROOT}/GoogleUtilitiesShims/module.modulemap"'
  include_path = '${PODS_ROOT}/GoogleUtilitiesShims'

  swift_includes = config.build_settings['SWIFT_INCLUDE_PATHS'] || '$(inherited)'
  unless swift_includes.to_s.include?('GoogleUtilitiesShims')
    config.build_settings['SWIFT_INCLUDE_PATHS'] = "#{swift_includes} #{include_path}"
  end

  other_swift = config.build_settings['OTHER_SWIFT_FLAGS'] || '$(inherited)'
  unless other_swift.to_s.include?('GoogleUtilitiesShims')
    config.build_settings['OTHER_SWIFT_FLAGS'] = "#{other_swift} -Xcc #{shim_flag}"
  end

  other_c = config.build_settings['OTHER_CFLAGS'] || '$(inherited)'
  unless other_c.to_s.include?('GoogleUtilitiesShims')
    config.build_settings['OTHER_CFLAGS'] = "#{other_c} #{shim_flag}"
  end
end

post_install do |installer|
  write_google_utilities_shims(installer.sandbox.root)

  installer.pods_project.build_configurations.each do |config|
    config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
    config.build_settings['CLANG_ENABLE_EXPLICIT_MODULES'] = 'NO'
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
      config.build_settings['CLANG_ENABLE_EXPLICIT_MODULES'] = 'NO'
      config.build_settings['DEFINES_MODULE'] = 'YES'
      append_shim_search_paths(config)
    end
  end

  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.xcconfigs.each_value do |xcconfig|
      xcconfig.attributes['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
      xcconfig.attributes['CLANG_ENABLE_EXPLICIT_MODULES'] = 'NO'
      includes = xcconfig.attributes['SWIFT_INCLUDE_PATHS'] || '$(inherited)'
      unless includes.include?('GoogleUtilitiesShims')
        xcconfig.attributes['SWIFT_INCLUDE_PATHS'] = "#{includes} ${PODS_ROOT}/GoogleUtilitiesShims"
      end
      flags = xcconfig.attributes['OTHER_SWIFT_FLAGS'] || '$(inherited)'
      unless flags.include?('GoogleUtilitiesShims')
        xcconfig.attributes['OTHER_SWIFT_FLAGS'] = "#{flags} -Xcc -fmodule-map-file=\"${PODS_ROOT}/GoogleUtilitiesShims/module.modulemap\""
      end
    end
    aggregate_target.xcconfigs.each do |config_name, xcconfig|
      xcconfig.save_as(aggregate_target.xcconfig_path(config_name))
    end

    aggregate_target.user_project.native_targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
        config.build_settings['CLANG_ENABLE_EXPLICIT_MODULES'] = 'NO'
      end
    end
    aggregate_target.user_project.build_configurations.each do |config|
      config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
      config.build_settings['CLANG_ENABLE_EXPLICIT_MODULES'] = 'NO'
    end
    aggregate_target.user_project.save
  end
end
