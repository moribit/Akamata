export const REALTIME_AUTHORIZE_PATH = "/__akamata/realtime/authorize";
export const REALTIME_MESSAGE_PATH = "/realtime/message";

export function realtimeNamespace(env) {
  const name = env?.AKAMATA_REALTIME_BINDING ?? "AKAMATA_REALTIME";
  return typeof name === "string" ? env?.[name] : undefined;
}

export function isInternalRealtimePath(pathname) {
  return pathname === "/__akamata/provider/realtime" || pathname === REALTIME_AUTHORIZE_PATH || pathname === REALTIME_MESSAGE_PATH;
}

export function rejectPublicInternalRoute(request) {
  return isInternalRealtimePath(new URL(request.url).pathname)
    ? Response.json({ error: "not_found" }, { status: 404 })
    : null;
}
