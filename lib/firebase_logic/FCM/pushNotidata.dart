import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "project-d281b",
      "private_key_id": "80186ca9591b39523aa92aa144bc553873af3265",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQChCctrH4S9w9mv\nJW3Kr3GzQSvKGB38OUsgq30NLQ5v82jrj7dOZpy/xPhXMpY4YpcyX+FN+IVMWR0/\nC5sSzQClc1gEMhJJ5RbfgvrUurDg5XHa2902UfffOkn2KxfwOaYuVn8W4AmkOJTC\nGV+03HQGhZHnWe+8FXuMbpx3g0ZhGfREx3gwUUzj+KutczJrIbuXaMnGh9aO2u4t\nxh96hIbDXv12Pt/6+x2eyk96NZU56Ar5h1Qt/KzxpE/EB/cU87s+8lSfSrX78gFX\nA79J6kB1L+ZtKknoBr9pZRo0iWHy6OA6uGTppne7M0fKoq97NgImCqYif0gylvDn\nzc/e+06NAgMBAAECggEATXynh0OSvTbUc1zYr/rshFrbBbLGFtvApRcvJFxmQoMG\nnLY59z0TtojCED8Unkv+Qax1/m0TQtHsay4b75d59KKEGvy25RyY/XKKXDr6qjRt\nLOi3UBBv61ciSJOiwKIUrt5K58hki0L4fU71SNL89zhlJMOXQdK6cK+2lSEzB7xQ\nZuYxdQVAf7XFtKeqQB/QgrQ4Z31nRYDBzI4rPYUgGK6yO9H1S5uYiWG6p0JxtETL\n/ZH1ocK9lJk7zIIaA7tv+TzXW+L4cVAaOmMPvKOhy4iEtxWfN1SY3OZ/2NWrGrEo\nRvFvBv5bNesXIky21adchqOOstUPAOkDLYbWC/Vz5wKBgQDPTD+nPgAOd0FcE9E5\n4h7ccKEt4l26WQi5HTPZt2eXFOBz8Rd3t27C2eWz6trwYAGJ0vULc5PFt/goA+34\nDYQdCLCHogd3sn52mOsUFeBxTAxfVySy8fM0bVcFs5vtqqUmxSkJvhCWojpWbenT\nJ9tLPkIoK51RI2J5js1X2gSBJwKBgQDG302DYnJiw//lPt6RsV6qeiJpulVhrnvy\nL3LkyCngJB535lFdXWKNp0vchFll6wFWNQBx6dxu3y59+YmxX2qOAb4arG2a2vB6\npPwYm/NyztSgPCuKEfF2Km9N7q8dqtxYR+C1MT+wFh3RnxB8evw8Eg6198s7UADh\nCnWMICGbKwKBgQCYQrAqXj7aYTvPrvqp4m26irvIoREpE8Z1eX6hNrZO4VWvs3EC\nTOh9FGFE0oc3sbzPh/TXEXCD9InAkopS/VKBpOVM6nVDtQZwhAd+/Eab0TjxOmfJ\nTC/P3VPi6zbnzcR6gqyO7Fzw1320CA2MPCU10ifzq31koHHvSTWIhqlyVwKBgQCj\nPC0il47uNJT5dSY5Dg52/bL7d3+XoyGHg5zZ3tZIbT05Cypj6T/4p4YkJdo/Rqsd\nOHn6Bovx0W0W59k2ZuxOTW3d9QQuJGFZOczW4kLsTIrITzsppFq+tEwR+sVwI4uj\nRrRR5W+yOCUXp2lf047wO54pjJAbSiq+jNg5QTJ0awKBgEfz7Q5kvI/kCFz5Wfnb\njUjfvhy63JGsJJOgyz0WrsWzLDggtARF1HNDOxrWqYy9rc6i6RzXepwzmGxhDzCf\nSXjmd8J1rMOHm8LSd9BYXJhM7tJdya4ZJBxbRrV+sGTItbMFgGXzmDnUh61o24lZ\nvkgKabZTu1mKlb5Vp10jc8x+\n-----END PRIVATE KEY-----\n",
      "client_email": "helloworld@project-d281b.iam.gserviceaccount.com",
      "client_id": "110944389158811827590",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/helloworld%40project-d281b.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
// close the client
    client.close();
    return credentials.accessToken.data;
  }
}
