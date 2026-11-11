import axios from "axios";
import { publicEnv } from "./env";

export const api = axios.create({
  baseURL: publicEnv.NEXT_PUBLIC_API_URL,
  headers: {
    Accept: "application/json",
  },
});
