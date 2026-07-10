# Face Validator

A Flutter project for offline face registration and face verification using **Google ML Kit** and **MobileFaceNet**. The application captures a user's face, generates facial embeddings locally on the device, and performs identity verification without requiring any backend service.

## Features

- Face registration with live camera capture
- Automatic capture when face quality requirements are met
- Single-face detection
- Face alignment using eye landmarks
- Face cropping and normalization
- Image sharpness (blur) validation
- Lighting validation
- Face embedding generation using MobileFaceNet (TensorFlow Lite)
- Multiple augmented embeddings for improved matching
- Offline face verification
- Local user storage using Hive

## Tech Stack

- Flutter
- Google ML Kit Face Detection
- TensorFlow Lite (MobileFaceNet)
- Camera
- Hive
- Provider

## Verification Pipeline

```
Register
    ↓
Live Face Detection
    ↓
Quality Validation
    ↓
Auto Capture
    ↓
Face Alignment
    ↓
Face Crop
    ↓
Blur Check
    ↓
Data Augmentation
    ↓
Generate Face Embeddings
    ↓
Store Locally

Validate
    ↓
Live Face Detection
    ↓
Quality Validation
    ↓
Auto Capture
    ↓
Face Alignment
    ↓
Face Crop
    ↓
Blur Check
    ↓
Generate Face Embeddings
    ↓
Cosine Similarity Comparison
    ↓
Verified / Rejected
```

## Current Validation Checks

- Single face detected
- Face inside guide
- Face size validation
- Head pose validation
- Eye visibility
- Lighting validation
- Blur detection

## Project Status

This project is  built to evaluate offline face recognition on Flutter. The focus is on demonstrating the complete registration and verification pipeline rather than production-ready security.

## Future Improvements

- Face liveness detection
- Anti-spoofing protection
- Improved alignment using facial landmarks
- Adaptive similarity thresholds
- Better lighting estimation
- Performance optimization
- Support for multiple registered users

## License

This project is intended for learning and demonstration purposes.
