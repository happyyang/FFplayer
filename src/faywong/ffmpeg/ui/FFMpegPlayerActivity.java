package faywong.ffmpeg.ui;

import android.app.Activity;

import android.content.Intent;

import android.os.Bundle;

import android.util.Log;

import com.media.ffmpeg.FFMpeg;
import com.media.ffmpeg.FFMpegException;
import com.media.ffmpeg.android.FFMpegMovieViewAndroid;

import faywong.ffmpeg.ui.R;

import java.io.IOException;

public class FFMpegPlayerActivity extends Activity {
    private static final String TAG = "FFMpegPlayerActivity";

    // private static final String   LICENSE = "This software uses libraries from the FFmpeg project under the LGPLv2.1";
    private FFMpegMovieViewAndroid mMovieView;

    // private WakeLock                              mWakeLock;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent i = getIntent();

        Log.d(TAG, "The intent: " + i + " data:" + i.getData());

        String filePath = i.getStringExtra(getResources().getString(R.string.input_file));

        if (filePath == null) {
            Log.d(TAG, "Not specified video file");
            finish();
        } else {

            // PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
            // mWakeLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, TAG);
            try {
                FFMpeg ffmpeg = new FFMpeg();
                mMovieView = ffmpeg.getMovieView(this);
                try {
                    mMovieView.setVideoPath(filePath);
                } catch (IllegalArgumentException e) {
                    Log.e(TAG, "Can't set video: " + e.getMessage());
                    FFMpegMessageBox.show(this, e);
                } catch (IllegalStateException e) {
                    Log.e(TAG, "Can't set video: " + e.getMessage());
                    FFMpegMessageBox.show(this, e);
                } catch (IOException e) {
                    Log.e(TAG, "Can't set video: " + e.getMessage());
                    FFMpegMessageBox.show(this, e);
                }
                setContentView(mMovieView);
            } catch (FFMpegException e) {
                Log.d(TAG, "Error when inicializing ffmpeg: " + e.getMessage());
                FFMpegMessageBox.show(this, e);
                finish();
            }
        }
    }

    @Override
    protected void onPause() {

        // TODO Auto-generated method stub
        super.onPause();
        FFMpegMessageBox.reCycle();
    }

    @Override
    protected void onDestroy() {

        // TODO Auto-generated method stub
        super.onDestroy();
        FFMpegMessageBox.reCycle();
    }

    @Override
    protected void onResume() {

        // TODO Auto-generated method stub
        Log.d(TAG, "onResume() called");
        super.onResume();
    }

    @Override
    protected void onStop() {

        // TODO Auto-generated method stub
        Log.d(TAG, "onStop() called");
        super.onStop();
    }
}