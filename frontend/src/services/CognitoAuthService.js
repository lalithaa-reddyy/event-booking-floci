class CognitoAuthService {
  static signUp(email, password, name) {
    return Promise.resolve({
      userSub: 'local-user-sub',
      username: email,
    });
  }

  static signIn(email, password) {
    localStorage.setItem('idToken', 'mock-id-token-' + Date.now());
    localStorage.setItem('accessToken', 'mock-access-token-' + Date.now());
    localStorage.setItem('user', JSON.stringify({ email, name: email }));

    return Promise.resolve({
      accessToken: localStorage.getItem('accessToken'),
      idToken: localStorage.getItem('idToken'),
      refreshToken: 'mock-refresh-token',
      expiresIn: 3600,
    });
  }

  static signOut() {
    localStorage.removeItem('idToken');
    localStorage.removeItem('accessToken');
    localStorage.removeItem('user');
  }

  static getCurrentUser() {
    try {
      const user = localStorage.getItem('user');
      if (!user) {
        return Promise.resolve(null);
      }

      const parsedUser = JSON.parse(user);
      return Promise.resolve({
        username: parsedUser.email,
        attributes: parsedUser,
        idToken: localStorage.getItem('idToken'),
        accessToken: localStorage.getItem('accessToken'),
      });
    } catch (error) {
      // If localStorage is corrupted, clear it and return null
      console.warn('Corrupted localStorage detected, clearing...', error);
      localStorage.clear();
      return Promise.resolve(null);
    }
  }

  static getIdToken() {
    return Promise.resolve(localStorage.getItem('idToken'));
  }
}

export default CognitoAuthService;
