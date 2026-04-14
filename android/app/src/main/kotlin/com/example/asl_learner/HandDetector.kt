package com.example.asl_learner

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult

class HandDetector(context: Context) {

    private val handLandmarker: HandLandmarker

    init {
        val baseOptions = BaseOptions.builder()
            .setModelAssetPath("hand_landmarker.task")
            .build()

        val options =
            HandLandmarker.HandLandmarkerOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.IMAGE)
                .setNumHands(1)
                .build()

        handLandmarker =
            HandLandmarker.createFromOptions(context, options)

        Log.d("HandDetector", "HandLandmarker initialized")
    }

    fun detect(bitmap: Bitmap): List<Double> {
        val mpImage = BitmapImageBuilder(bitmap).build()
        val result: HandLandmarkerResult =
            handLandmarker.detect(mpImage)

        if (result.landmarks().isEmpty()) {
            Log.d("HandDetector", "No hand detected")
            return emptyList()
        }

        val hand = result.landmarks()[0]
        val output = ArrayList<Double>(63)

        for (lm in hand) {
            output.add(lm.x().toDouble())
            output.add(lm.y().toDouble())
            output.add(lm.z().toDouble())
        }

        Log.d("HandDetector", "Hand detected with ${hand.size} landmarks")
        return output
    }
}
