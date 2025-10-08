# Google Places API Setup Guide

## Overview
This app uses Google Places API for location autocomplete functionality, providing better and more accurate location suggestions than manual databases.

## Setup Steps

### 1. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your project ID

### 2. Enable Places API
1. In the Google Cloud Console, go to "APIs & Services" → "Library"
2. Search for "Places API"
3. Click on "Places API" and click "Enable"

### 3. Create API Key
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Copy the generated API key

### 4. Restrict API Key (Important for Security)
1. Click on the API key you just created
2. Under "Application restrictions":
   - Select "iOS apps"
   - Click "Add an item"
   - Enter your app's bundle identifier (found in your Xcode project settings)
3. Under "API restrictions":
   - Select "Restrict key"
   - Choose "Places API" from the list
4. Click "Save"

### 5. Add API Key to Your App
1. Open `GooglePlacesConfig.swift`
2. Replace `"YOUR_GOOGLE_PLACES_API_KEY"` with your actual API key
3. Make sure not to commit this file with your real API key to version control

### 6. Test the Setup
1. Run your app
2. Go to the calendar setup flow
3. Try typing in the location fields - you should see Google Places suggestions

## Security Best Practices

- Never hardcode API keys in your source code for production apps
- Use environment variables or secure configuration files
- Add bundle ID restrictions to prevent unauthorized usage
- Monitor your API usage in Google Cloud Console
- Set up billing alerts to avoid unexpected charges

## Troubleshooting

### "API key not configured" message
- Check that you've replaced the placeholder in `GooglePlacesConfig.swift`
- Verify the API key is correct (no extra spaces or characters)

### No suggestions appearing
- Ensure Places API is enabled in Google Cloud Console
- Check that your API key has proper iOS app restrictions
- Verify your bundle ID matches the restriction
- Check the Xcode console for error messages

### "This API key is not authorized" error
- Double-check your bundle ID restriction
- Make sure Places API is selected in API restrictions
- Wait a few minutes after making changes (can take time to propagate)

## Fallback Behavior

If the Google Places API is not configured or fails, the app will automatically use simple fallback suggestions. This ensures the app continues to work even without the API configured, though with reduced functionality.

## Cost Considerations

Google Places API has usage-based pricing. The autocomplete requests used in this app typically cost $0.00283 per session. Monitor your usage in the Google Cloud Console and set up billing alerts if needed.

For development and testing, Google provides a generous free tier that should cover most development needs.