# Troubleshooting Guide

## "Cannot connect to Binance API" Error

If you're getting this error, here are the steps to diagnose and fix the issue:

### 1. Check Your Internet Connection
- Make sure you have a stable internet connection
- Try opening a web browser and visiting https://www.binance.com
- If you can't access Binance website, the issue is with your internet connection

### 2. Test API Connectivity
- Use the "Test Connection" button in the login screen
- This will show you detailed information about what's working and what's not

### 3. Check Your API Credentials
Make sure your API credentials are correct:
- **API Key**: Should be a long string of letters and numbers
- **Secret Key**: Should be a long string of letters and numbers
- **Case Sensitive**: Make sure there are no extra spaces or wrong characters

### 4. Verify API Permissions
Your Binance API key needs the right permissions:
1. Go to Binance.com → Account → API Management
2. Find your API key and click "Edit restrictions"
3. Make sure "Enable Spot & Margin Trading" is checked
4. **Important**: Do NOT enable "Enable Withdrawals" for security

### 5. Try Testnet First
If you're having issues with the live API:
1. Toggle "Use Testnet" in the login screen
2. Create testnet API keys at https://testnet.binance.vision/
3. Test with testnet credentials first

### 6. Check Your Network/Firewall
Some networks block cryptocurrency-related websites:
- **Corporate Networks**: Many companies block crypto sites
- **School Networks**: Educational institutions often block trading sites
- **Public WiFi**: Some public networks have restrictions
- **VPN**: If using a VPN, try disconnecting it
- **Firewall**: Check if your firewall is blocking the app

### 7. Regional Restrictions
Binance may not be available in your region:
- Check if Binance is available in your country
- Some regions have restricted access to Binance
- Consider using Binance.US if you're in the United States

### 8. API Rate Limits
If you've been testing a lot:
- Binance has rate limits on API calls
- Wait a few minutes before trying again
- The limits reset automatically

### 9. Server Time Synchronization
API requests require accurate time:
- Make sure your device's time is correct
- The app automatically handles time synchronization
- If issues persist, check your system clock

### 10. Common Error Messages and Solutions

#### "Invalid API Key"
- Double-check your API key for typos
- Make sure you're using the correct key (not the secret)
- Regenerate your API key if needed

#### "Invalid Signature"
- Check your secret key for typos
- Make sure there are no extra spaces
- Try regenerating both API key and secret

#### "IP Restriction"
- If you set IP restrictions on your API key, make sure your current IP is allowed
- Consider removing IP restrictions for testing

#### "Timestamp for this request is outside the recvWindow"
- Your device's clock might be wrong
- The app handles this automatically, but check your system time

### 11. Testing Steps

1. **Basic Internet Test**:
   ```
   Open browser → Go to https://www.google.com
   If this fails, fix your internet connection first
   ```

2. **Binance Website Test**:
   ```
   Open browser → Go to https://www.binance.com
   If this fails, check network restrictions
   ```

3. **API Endpoint Test**:
   ```
   Use the "Test Connection" button in the app
   This will show detailed connection information
   ```

4. **Testnet Test**:
   ```
   Toggle "Use Testnet" → Create testnet API keys → Try login
   If testnet works but live doesn't, check live API permissions
   ```

### 12. Getting Help

If none of these steps work:

1. **Use the Test Connection button** to get detailed diagnostic information
2. **Check the error message** carefully - it often contains specific clues
3. **Try testnet first** to isolate the issue
4. **Check Binance status** at https://www.binance.com/en/support/announcement
5. **Verify your region** supports Binance trading

### 13. Security Notes

- Never share your API keys with anyone
- Don't enable withdrawal permissions unless absolutely necessary
- Use testnet for learning and testing
- Keep your API keys secure and rotate them regularly

### 14. Alternative Solutions

If you continue having issues:
- Try using a different network (mobile hotspot vs WiFi)
- Test at a different time of day
- Check if your ISP blocks cryptocurrency sites
- Consider using a different device to test

Remember: The "Test Connection" button in the app will give you the most specific information about what's not working in your particular situation.