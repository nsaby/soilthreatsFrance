if (need2fit == TRUE) {
  
  profiles_overlay(
    profilesStandardFile = config$profilesStandardFile,
    covarsDir = config$covarsDir,
    profilesOverlayFile = config$profilesOverlayFile,
    covariatesListFile = config$covariatesListFile,
    outputDir = config$outputDir,
    easting_name = config$easting_name,
    northing_name = config$northing_name,
    crs_profiles = config$crs_profiles,
    pid_name = config$pid_name,
    covariate_pattern = config$covariate_pattern,overwrite = config$overwrite
  )
  
  layers_depth(
    layersStandardFile = config$layersStandardFile,
    layersDepthProcessedFile = config$layersDepthProcessedFile,
    outputDir = config$outputDir,
    pid_name = config$pid_name,
    lyrid_name = config$lyrid_name,
    top_layer_name = config$top_layer_name,
    bottom_layer_name = config$bottom_layer_name,
    depth_name = config$depth_name,
    depths_3D = config$depths_3D,
    thick_cond = config$thick_cond,overwrite = config$overwrite
  )
  
  profiles_folds(
    profilesStandardFile = config$profilesStandardFile,
    profilesFoldsFile = config$profilesFoldsFile,
    outputDir = config$outputDir,
    pid_name = config$pid_name,
    easting_name = config$easting_name, northing_name = config$northing_name,
    fold_name = config$fold_name,
    n_folds = config$n_folds,
    rndseed = config$rndseed, use_dggridR = config$use_dggridR,
    dggrid_resolution = config$dggrid_resolution,
    stratum_name = config$stratum_name,overwrite = config$overwrite
  )
  
  regression_matrix(
    voi = config$voi,
    profilesOverlayFile = config$profilesOverlayFile,
    layersDepthProcessedFile = config$layersDepthProcessedFile,
    profilesFoldsFile = config$profilesFoldsFile,
    covariatesListFile = config$covariatesListFile,
    regressionMatrixFile = config$regressionMatrixFile,
    outputDir = config$outputDir,
    pid_name = config$pid_name,
    lyrid_name = config$lyrid_name,
    fold_name = config$fold_name,
    easting_name = config$easting_name,
    northing_name = config$northing_name,
    depth_name = config$depth_name,
    stratum_name = config$stratum_name,
    depth_column_name = config$depth_column_name,
    voi_min_value = config$voi_parameters$voi_min_value, 
    voi_max_value = config$voi_parameters$voi_max_value,
    overwrite = config$overwrite
  )
  
  
  # ## Model
  if (config$use_rfe == "dorfe") {
    run_rfe(
      voi = config$voi,
      regressionMatrixFile = config$regressionMatrixFile,
      rfeMetricsProfileFile = config$rfeMetricsProfileFile,
      rfeCovariatesFile = config$rfeCovariatesFile,
      outputDir = config$outputDir,
      transformation = config$voi_parameters$transformation,
      rfe_number = config$rfe_number,
      cores = config$cores, 
      rndseed = config$rndseed,
      pid_name = config$pid_name,
      lyrid_name = config$lyrid_name,
      fold_name = config$fold_name,
      depth_name = config$depth_name,
      depth_column_name = config$depth_column_name,
      overwrite = config$overwrite
    )
  }
  
  if (config$do_tune == "tune") {
    model_tune(
      voi = config$voi,
      regressionMatrixFile = config$regressionMatrixFile,
      tuningGridFile = config$tuningGridFile,
      bestParamFile = config$bestParamFile,
      rfeCovariatesFile = config$rfeCovariatesFile,
      outputDir = config$outputDir, model_name = config$model_name,
      pid_name = config$pid_name, lyrid_name = config$lyrid_name,
      depth_name = config$depth_name,
      transformation = config$voi_parameters$transformation, 
      use_rfe = config$use_rfe,
      fold_name = config$fold_name, tune_metric = config$tune_metric,
      depth_column_name = config$depth_column_name,
      rndseed = config$rndseed,
      cores = config$cores,
      model_options = config$model_options[[config$model_name]],
      overwrite = config$overwrite
    )
  }
  
  model_cv(
    voi = config$voi,
    regressionMatrixFile = config$regressionMatrixFile,
    rfeCovariatesFile = config$rfeCovariatesFile,
    bestParamFile = config$bestParamFile,
    cvMetricsFile = config$cvMetricsFile,
    cvPredictObserveFile = config$cvPredictObserveFile,
    outputDir = config$outputDir,
    model_name = config$model_name,
    do_tune = config$do_tune,
    transformation = config$voi_parameters$transformation,
    use_rfe = config$use_rfe, pid_name = config$pid_name,
    lyrid_name = config$lyrid_name, fold_name = config$fold_name,
    depth_name = config$depth_name,
    depth_column_name = config$depth_column_name,
    cores = config$cores,
    model_options = config$model_options[[config$model_name]],
    rndseed = config$rndseed,overwrite = config$overwrite
  )
  
  model_fit(
    voi = config$voi, regressionMatrixFile = config$regressionMatrixFile,
    bestParamFile = config$bestParamFile,
    rfeCovariatesFile = config$rfeCovariatesFile,
    modelFittedFile = config$modelFittedFile,
    internalMetricsFile = config$internalMetricsFile,
    outputDir = config$outputDir,
    use_rfe = config$use_rfe, do_tune = config$do_tune,
    transformation = config$voi_parameters$transformation, 
    rndseed = config$rndseed,
    depth_name = config$depth_name, pid_name = config$pid_name,
    fold_name = config$fold_name, lyrid_name = config$lyrid_name,
    depth_column_name = config$depth_column_name,
    model_name = config$model_name,
    model_options = config$model_options[[config$model_name]],
    overwrite = config$overwrite
  )
  
  
  
}


if (prediction  == TRUE ) {
  
  # ## Predict
  make_tiles(
    maskFile = config$maskFile, tileside = config$tileside, tilesFile = config$tilesFile,
    tilesFileGpkg = config$tilesFileGpkg, outputDir = config$outputDir,
    NA_mask_flag = config$NA_mask_flag,overwrite = config$overwrite
  )
  
  predict_tiles(
    voi = config$voi, tilesFile = config$tilesFile,
    covarsDir = config$covarsDir,
    rfeCovariatesFile = config$rfeCovariatesFile, maskFile = config$maskFile,
    modelFittedFile = config$modelFittedFile, tilesDir = config$tilesDir,
    outputDir = config$outputDir, depth_name = config$depth_name,
    transformation = config$voi_parameters$transformation, 
    use_rfe = config$use_rfe,
    do_tune = config$do_tune, multiply = config$multiply,
    gdal_options = config$gdal_options,
    datatype_geotiff = config$datatype_geotiff, depths_3D = config$depths_3D,
    covariate_pattern = config$covariate_pattern,
    NA_mask_flag = config$NA_mask_flag, cores = config$cores,
    rndseed = config$rndseed,
    model_name = config$model_name,
    model_options = config$model_options[[config$model_name]],
    overwrite = config$overwrite
  )
  
  
  mosaic_tiles(
    tilesDir = config$tilesDir, predictedMapVrt = config$predictedMapVrt,
    outputDir = config$outputDir, voi = config$voi,
    model_name = config$model_name, depth_name = config$depth_name,
    transformation = config$voi_parameters$transformation, 
    use_rfe = config$use_rfe,
    do_tune = config$do_tune, gdal_output_driver = config$gdal_output_driver,
    gdal_options = config$gdal_options,
    datatype_geotiff = config$datatype_geotiff, multiband = config$multiband,
    crs_out = config$crs_out
  )
  
  plot_maps_terra(
    tilesDir = config$tilesDir, plotDir = config$plotDir,
    outputDir = config$outputDir, voi = config$voi,
    model_name = config$model_name, depth_name = config$depth_name,
    transformation = config$voi_parameters$transformation, 
    use_rfe = config$use_rfe,
    do_tune = config$do_tune, plot_border = config$plot_border,
    divideBy = config$multiply, legend_title = config$legend_title,
    add_north = config$add_north, add_sbar = config$add_sbar,
    save_to_disk = config$save_to_disk
  )
  
  
}

