'use client';

import { Loading } from 'react-basics';
import Script from 'next/script';
import { useEffect } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import { useLogin, useConfig } from 'components/hooks';
import UpdateNotice from './UpdateNotice';

export function App({ children }) {
  const { user, isLoading, error } = useLogin();
  const config = useConfig();
  const pathname = usePathname();
  const router = useRouter();

  // Extract token and store it in localStorage
  useEffect(() => {
    const token = new URLSearchParams(window.location.search).get('token');
    if (token) {
      const decodedToken = decodeURIComponent(token);
      // console.log("setting token on page load----------",decodedToken,user,"00--00",error, isLoading)
      localStorage.setItem('umami.auth', `"${decodedToken}"`);
      localStorage.setItem('umami.theme', `"light"`);
    }
  }, []);

  if (isLoading) {
    return <Loading />;
  }

  if (error) {
    router.push(`${process.env.basePath || ''}/login`);
    return null; // Prevent rendering of children during redirection
  }

  if (!user || !config) {
    return null;
  }

  return (
    <>
      {children}
      <UpdateNotice user={user} config={config} />
      {process.env.NODE_ENV === 'production' && !pathname.includes('/share/') && (
        <Script src={`${process.env.basePath || ''}/telemetry.js`} />
      )}
    </>
  );
}

export default App;
