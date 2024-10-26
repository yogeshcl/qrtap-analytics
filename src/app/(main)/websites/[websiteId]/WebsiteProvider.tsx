'use client';
import { createContext, ReactNode, useEffect, useState } from 'react';
import { useModified, useWebsite } from 'components/hooks';
import { Loading } from 'react-basics';

export const WebsiteContext = createContext(null);

export function WebsiteProvider({
  websiteId,
  children,
}: {
  websiteId: string;
  children: ReactNode;
}) {
  const { modified } = useModified(`website:${websiteId}`);
  const { data: website, isFetching, isLoading, refetch } = useWebsite(websiteId);

  useEffect(() => {
    if (modified) {
      refetch();
    }
  }, [modified]);

  const [isTokenStored, setIsTokenStored] = useState(false);

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const token = urlParams.get('token');

    if (token) {
      const decodedToken = decodeURIComponent(token);
      // console.log("setting token",decodedToken)
      localStorage.setItem('umami.auth', `"${decodedToken}"`);
      setIsTokenStored(true);
    } else {
      setIsTokenStored(true); // Set true to allow rendering without token if needed
    }
  }, []);

  if ((isFetching && isLoading) || !isTokenStored) {
    return <Loading position="page" />;
  }

  return <WebsiteContext.Provider value={website}>{children}</WebsiteContext.Provider>;
}

export default WebsiteProvider;
