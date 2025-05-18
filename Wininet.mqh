#property copyright "Copyright 2015, Wemerson C. Guimaraes"
#property link "https://www.mql5.com/pt/users/wemersonrv/seller"

#define READURL_BUFFER_SIZEX 100
#define HTTP_QUERY_STATUS_CODE 19

#import "wininet.dll"
    int InternetOpenW(string, int, string, string, int);
    int InternetConnectW(int, string, int, string, string, int, int, int);
    int HttpOpenRequestW(int, string, string, int, string, int, string, int);
    int InternetOpenUrlW(int, string, string, int, int, int);
    int InternetReadFile(int, uchar & arr[], int, int& OneInt[]);
    int InternetCloseHandle(int);
    int HttpQueryInfoW(int ,int ,uchar &lpvBuffer[],int& lpdwBufferLength, int& lpdwIndex);
#import

void ReadUrl(string url, string& data)
{
    int HttpOpen = InternetOpenW(" ", 0, " ", " ", 0);
    int HttpConnect = InternetConnectW(HttpOpen, "", 80, "", "", 3, 0, 1);
    int HttpRequest = InternetOpenUrlW(HttpOpen, url, NULL, 0, 0, 0);

    uchar cBuff[5];

    int cBuffLength = 10;
    int cBuffIndex = 0;
    int HttpQueryInfoW = HttpQueryInfoW(HttpRequest, HTTP_QUERY_STATUS_CODE, cBuff, cBuffLength, cBuffIndex);

    // HTTP Codes... Only the 1st character (4xx, 5xx, etc)
    int http_code = (int) CharArrayToString(cBuff, 0, WHOLE_ARRAY, CP_UTF8);

    if (http_code == 4 || http_code == 5) { // 4XX || 5XX
        Print("O ENVIO ACIMA GEROU UM ERRO | [ HTTP Error ] ", http_code, "XX");

        if (HttpRequest > 0) {
            InternetCloseHandle(HttpRequest);
        }

        if (HttpConnect > 0) {
            InternetCloseHandle(HttpConnect);
        }

        if (HttpOpen > 0) {
            InternetCloseHandle(HttpOpen);
        }

        data = "HTTP_ERROR";
    } else {
        int read[1];

        uchar Buffer[];

        ArrayResize(Buffer, READURL_BUFFER_SIZEX + 1);

        data = "";

        while (true) {
            InternetReadFile(HttpRequest, Buffer, READURL_BUFFER_SIZEX, read);

            string strThisRead = CharArrayToString(Buffer, 0, read[0], CP_UTF8);

            if (read[0] > 0) {
                data = data + strThisRead;
            } else {
                break;
            }
        }
    }

    if (HttpRequest > 0) {
        InternetCloseHandle(HttpRequest);
    }

    if (HttpConnect > 0) {
        InternetCloseHandle(HttpConnect);
    }

    if (HttpOpen > 0) {
        InternetCloseHandle(HttpOpen);
    }
}